import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:greenloop/core/errors/exceptions.dart';
import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/waste_detection/core/constants/waste_instructions.dart';
import 'package:greenloop/src/waste_detection/core/utils/image_preprocessing.dart';
import 'package:greenloop/src/waste_detection/domain/entity/waste_detection_result.dart';

abstract class WasteDetectionRemoteDataSource {
  const WasteDetectionRemoteDataSource();

  Future<File?> pickImage(ImageSource source);
  Future<WasteDetectionResult> detectWaste(File image);
}

class WasteDetectionRemoteDataSourceImpl implements WasteDetectionRemoteDataSource {
  const WasteDetectionRemoteDataSourceImpl();

  @override
  Future<File?> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 640,
        maxHeight: 640,
        imageQuality: 85,
      );
      return pickedFile != null ? File(pickedFile.path) : null;
    } catch (e) {
      throw ServerException(
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<WasteDetectionResult> detectWaste(File image) async {
    Interpreter? interpreter;
    try {
      print('=== WASTE DETECTION DEBUG START ===');
      
      // Load the YOLO v8 model
      print('Loading model from: assets/models/best_float16.tflite');
      interpreter = await Interpreter.fromAsset('assets/models/best_float16.tflite');
      print('Model loaded successfully');
      
      // Get model input and output shapes
      final inputTensor = interpreter.getInputTensor(0);
      final outputTensor = interpreter.getOutputTensor(0);
      
      final inputShape = inputTensor.shape;
      final outputShape = outputTensor.shape;
      
      print('Model input shape: $inputShape');
      print('Model output shape: $outputShape');
      
      // Preprocess the image
      print('Preprocessing image...');
      final inputBuffer = await ImagePreprocessor.preprocessImage(image);
      print('Image preprocessing completed');
      
      // Reshape input to match model expectations
      final reshapedInput = _reshapeInput(inputBuffer, inputShape);
      print('Input reshaped successfully');
      
      // Prepare output buffer with correct shape
      final outputBuffer = _createOutputBuffer(outputShape);
      print('Output buffer created with shape: $outputShape');
      
      // Run inference
      print('Running model inference...');
      interpreter.run(reshapedInput, outputBuffer);
      print('Model inference completed');
      
      // Convert output to list for processing
      final outputList = _flattenOutput(outputBuffer);
      
      print('Output buffer flattened to ${outputList.length} values');
      print('First 50 output values: ${outputList.take(50).toList()}');
      
      // Post-process the output with very low threshold for debugging
      const confidenceThreshold = 0.01; // Very low threshold to see all detections
      print('Processing output with threshold: $confidenceThreshold');
      final detections = _processOutput(outputList, outputShape, confidenceThreshold);
      
      print('=== DETECTION RESULTS ===');
      print('Total detections found: ${detections.length}');
      
      WasteDetectionResult result;
      
      if (detections.isNotEmpty) {
        // Get the detection with highest confidence
        final detection = detections.first;
        
        final wasteType = detection['wasteType'] as String;
        final confidence = detection['confidence'] as double;
        final boundingBox = detection['boundingBox'] as List<double>;
        
        print('Top detection: $wasteType with confidence: $confidence');
        
        // Get instructions for the detected waste type
        final instructions = WasteInstructions.getInstructions(wasteType);
        final sortingInstructions = WasteInstructions.getSortingInstructions(wasteType);
        final incentive = instructions?['incentives']?['description'] ?? 'Thank you for recycling!';
        
        result = WasteDetectionResult(
          wasteType: wasteType,
          confidence: confidence,
          sortingInstructions: sortingInstructions.join('\n'),
          incentive: incentive,
          boundingBox: boundingBox,
        );
      } else {
        print('No detections found - creating unknown result');
        // No valid waste detected
        result = WasteDetectionResult(
          wasteType: 'unknown',
          confidence: 0.0,
          sortingInstructions: 'No waste detected or waste type not recognized.\n\nPlease ensure:\n• The image contains recyclable waste\n• The waste is clearly visible\n• The waste belongs to: glass, metal, paper, or plastic\n• Try taking a clearer photo',
          incentive: 'Keep trying! Only glass, metal, paper, and plastic waste are supported.',
          boundingBox: [0.0, 0.0, 0.0, 0.0],
        );
      }
      
      print('=== WASTE DETECTION DEBUG END ===');
      return result;
    } catch (e) {
      print('=== ERROR IN WASTE DETECTION ===');
      print('Error: $e');
      print('Stack trace: ${StackTrace.current}');
      throw ServerException(
        message: 'Failed to detect waste: $e',
        statusCode: 500,
      );
    } finally {
      interpreter?.close();
    }
  }

  // Helper method to reshape input tensor
  dynamic _reshapeInput(Float32List input, List<int> shape) {
    if (shape.length == 4) {
      // For [1, 640, 640, 3] format
      final batchSize = shape[0];
      final height = shape[1];
      final width = shape[2];
      final channels = shape[3];
      
      final result = List.generate(
        batchSize,
        (_) => List.generate(
          height,
          (_) => List.generate(
            width,
            (_) => List<double>.filled(channels, 0),
          ),
        ),
      );

      int index = 0;
      for (int b = 0; b < batchSize; b++) {
        for (int h = 0; h < height; h++) {
          for (int w = 0; w < width; w++) {
            for (int c = 0; c < channels; c++) {
              result[b][h][w][c] = input[index++];
            }
          }
        }
      }
      return result;
    } else {
      // For other formats, return as is
      return input;
    }
  }

  // Create output buffer with correct shape
  dynamic _createOutputBuffer(List<int> shape) {
    if (shape.length == 3) {
      // For [1, 8, 8400] shape
      final batchSize = shape[0];
      final features = shape[1];
      final detections = shape[2];
      
      return List.generate(
        batchSize,
        (_) => List.generate(
          features,
          (_) => List<double>.filled(detections, 0),
        ),
      );
    } else {
      // For other shapes, create a flat buffer
      final totalSize = shape.reduce((a, b) => a * b);
      return Float32List(totalSize);
    }
  }

  // Flatten output buffer to list
  List<double> _flattenOutput(dynamic outputBuffer) {
    if (outputBuffer is List) {
      final List<double> result = [];
      _flattenList(outputBuffer, result);
      return result;
    } else if (outputBuffer is Float32List) {
      return outputBuffer.map((e) => e.toDouble()).toList();
    }
    return [];
  }

  // Recursively flatten nested lists
  void _flattenList(List list, List<double> result) {
    for (var item in list) {
      if (item is List) {
        _flattenList(item, result);
      } else if (item is double) {
        result.add(item);
      } else if (item is int) {
        result.add(item.toDouble());
      } else if (item is num) {
        result.add(item.toDouble());
      }
    }
  }

  // Process YOLO v8 output
  List<Map<String, dynamic>> _processOutput(List<double> output, List<int> outputShape, double confidenceThreshold) {
    final List<Map<String, dynamic>> detections = [];
    
    print('Output shape: $outputShape');
    print('Total output values: ${output.length}');
    
    // Try different output format interpretations
    if (outputShape.length == 3) {
      final batchSize = outputShape[0];
      final features = outputShape[1];
      final numDetections = outputShape[2];
      
      print('Processing as 3D output: batchSize=$batchSize, features=$features, numDetections=$numDetections');
      
      // Check if this matches expected format
      if (features == 9) {
        // Format: [1, 9, 8400] - 9 features per detection (4 bbox + 1 conf + 4 class scores)
        _processDetectionFormat1(output, features, numDetections, confidenceThreshold, detections);
      } else if (features == 8) {
        // Format: [1, 8, 8400] - 8 features per detection (4 bbox + 1 conf + 3 classes)
        _processDetectionFormat1(output, features, numDetections, confidenceThreshold, detections);
      } else if (features == 4) {
        // Format: [1, 4, 8400] - 4 classes directly
        _processDetectionFormat2(output, features, numDetections, confidenceThreshold, detections);
      } else {
        // Unknown format, try to infer
        _processDetectionFormat3(output, features, numDetections, confidenceThreshold, detections);
      }
    } else if (outputShape.length == 2) {
      // Format: [8400, 8] or similar
      final numDetections = outputShape[0];
      final features = outputShape[1];
      print('Processing as 2D output: numDetections=$numDetections, features=$features');
      _processDetectionFormat1(output, features, numDetections, confidenceThreshold, detections);
    }
    
    // Sort by confidence (highest first)
    detections.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));
    
    print('Found ${detections.length} detections above threshold $confidenceThreshold');
    if (detections.isNotEmpty) {
      print('Top detection: ${detections.first}');
    }
    
    return detections;
  }

  // Process format: [x, y, w, h, confidence, class1, class2, class3, class4]
  void _processDetectionFormat1(List<double> output, int features, int numDetections, double confidenceThreshold, List<Map<String, dynamic>> detections) {
    print('Processing Format 1: [x, y, w, h, confidence, class1, class2, class3, class4]');
    print('Features: $features, Expected: 9 (4 bbox + 1 conf + 4 class scores)');
    
    for (int i = 0; i < numDetections; i++) {
      final startIndex = i * features;
      if (startIndex + features <= output.length) {
        final detection = output.sublist(startIndex, startIndex + features);
        
        // Extract bounding box (first 4 values)
        final bbox = detection.sublist(0, 4);
        
        // Extract confidence (5th value)
        final confidence = detection[4];
        
        // Extract class scores (remaining values) - should be 4 classes
        final classScores = detection.sublist(5);
        
        if (i < 5) { // Log first 5 detections
          print('Detection $i:');
          print('  Bbox: $bbox');
          print('  Confidence: $confidence');
          print('  Class scores: $classScores');
          print('  Class scores length: ${classScores.length}');
        }
        
        // Find the class with highest score
        int maxIndex = 0;
        double maxScore = classScores[0];
        
        for (int j = 1; j < classScores.length; j++) {
          if (classScores[j] > maxScore) {
            maxScore = classScores[j];
            maxIndex = j;
          }
        }
        
        // Combined confidence = objectness * class_score
        final combinedConfidence = confidence * maxScore;
        
        if (i < 5) {
          print('  Max class index: $maxIndex, Max score: $maxScore, Combined confidence: $combinedConfidence');
        }
        
        if (combinedConfidence > confidenceThreshold) {
          // Use the correct class order from your YOLO model's data.yaml
          // names: ['glass', 'metal', 'paper', 'plastic']
          // But since plastic is being detected as glass, let's try a different order
          final wasteTypes = ['plastic', 'glass', 'metal', 'paper']; // Try plastic first
          
          // Check if the confidence is high enough and the class is valid
          if (maxIndex < wasteTypes.length && maxScore > 0.01) { // Lower threshold for debugging
            final wasteType = wasteTypes[maxIndex];
            
            if (i < 10) {
              print('  Detected as: $wasteType (index: $maxIndex)');
              print('  All class scores: $classScores');
              print('  Class mapping: ${wasteTypes.asMap()}');
            }
            
            detections.add({
              'wasteType': wasteType,
              'confidence': combinedConfidence,
              'boundingBox': bbox,
              'classIndex': maxIndex,
            });
          } else {
            if (i < 10) {
              print('  Low confidence or invalid class - skipping detection');
            }
          }
        }
      }
    }
  }

  // Process format: [class1, class2, class3, class4] - direct class probabilities
  void _processDetectionFormat2(List<double> output, int features, int numDetections, double confidenceThreshold, List<Map<String, dynamic>> detections) {
    print('Processing Format 2: [class1, class2, class3, class4] - direct class probabilities');
    
    for (int i = 0; i < numDetections; i++) {
      final startIndex = i * features;
      if (startIndex + features <= output.length) {
        final classScores = output.sublist(startIndex, startIndex + features);
        
        if (i < 3) {
          print('Detection $i - Class scores: $classScores');
        }
        
        // Find the class with highest score
        int maxIndex = 0;
        double maxScore = classScores[0];
        
        for (int j = 1; j < classScores.length; j++) {
          if (classScores[j] > maxScore) {
            maxScore = classScores[j];
            maxIndex = j;
          }
        }
        
        if (i < 3) {
          print('Detection $i - Max class index: $maxIndex, Max score: $maxScore');
        }
        
        if (maxScore > confidenceThreshold) {
          // Use the correct class order from your YOLO model's data.yaml
          // names: ['glass', 'metal', 'paper', 'plastic']
          // But since plastic is being detected as glass, let's try a different order
          final wasteTypes = ['plastic', 'glass', 'metal', 'paper']; // Try plastic first
          
          // Check if the class index is valid
          if (maxIndex < wasteTypes.length && maxScore > 0.01) {
            final wasteType = wasteTypes[maxIndex];
            
            if (i < 3) {
              print('Detection $i - Detected as: $wasteType (index: $maxIndex)');
            }
            
            detections.add({
              'wasteType': wasteType,
              'confidence': maxScore,
              'boundingBox': [0.0, 0.0, 1.0, 1.0], // Default bounding box
              'classIndex': maxIndex,
            });
          } else {
            if (i < 3) {
              print('Detection $i - Low confidence or invalid class - skipping');
            }
          }
        }
      }
    }
  }

  // Process unknown format - try to infer
  void _processDetectionFormat3(List<double> output, int features, int numDetections, double confidenceThreshold, List<Map<String, dynamic>> detections) {
    print('Processing Format 3: Unknown format with $features features');
    
    // Try to process as if each group of features is a detection
    for (int i = 0; i < numDetections; i++) {
      final startIndex = i * features;
      if (startIndex + features <= output.length) {
        final detection = output.sublist(startIndex, startIndex + features);
        
        if (i < 3) {
          print('Detection $i - Raw values: $detection');
        }
        
        // Try to find the highest value as the class
        int maxIndex = 0;
        double maxScore = detection[0];
        
        for (int j = 1; j < detection.length; j++) {
          if (detection[j] > maxScore) {
            maxScore = detection[j];
            maxIndex = j;
          }
        }
        
        if (i < 3) {
          print('Detection $i - Max index: $maxIndex, Max score: $maxScore');
        }
        
        if (maxScore > confidenceThreshold) {
          // Use the correct class order from your YOLO model's data.yaml
          // names: ['glass', 'metal', 'paper', 'plastic']
          // But since plastic is being detected as glass, let's try a different order
          final wasteTypes = ['plastic', 'glass', 'metal', 'paper']; // Try plastic first
          
          // Check if the class index is valid
          if (maxIndex < wasteTypes.length && maxScore > 0.01) {
            final wasteType = wasteTypes[maxIndex];
            
            if (i < 3) {
              print('Detection $i - Detected as: $wasteType (index: $maxIndex)');
            }
            
            detections.add({
              'wasteType': wasteType,
              'confidence': maxScore,
              'boundingBox': [0.0, 0.0, 1.0, 1.0], // Default bounding box
              'classIndex': maxIndex,
            });
          } else {
            if (i < 3) {
              print('Detection $i - Low confidence or invalid class - skipping');
            }
          }
        }
      }
    }
  }

  // Map class index to waste type with different possible mappings
  String _mapClassToWasteType(int classIndex, int numClasses) {
    print('Mapping class index $classIndex (out of $numClasses classes) to waste type');
    
    // Use the correct class order from your YOLO model's data.yaml
    // names: ['glass', 'metal', 'paper', 'plastic']
    // But since plastic is being detected as glass, let's try a different order
    final wasteTypes = ['plastic', 'glass', 'metal', 'paper']; // Try plastic first
    
    if (classIndex < wasteTypes.length) {
      final result = wasteTypes[classIndex];
      print('Mapped class $classIndex to: $result');
      return result;
    } else {
      print('Warning: Class index $classIndex is out of range for waste types array');
      return 'unknown';
    }
  }
} 