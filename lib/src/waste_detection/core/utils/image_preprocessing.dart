import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ImagePreprocessor {
  static const int inputSize = 640; // YOLO v8 standard input size

  static Future<Float32List> preprocessImage(File imageFile) async {
    try {
      // Read image file
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      print('Original image size: ${image.width}x${image.height}');

      // Resize to 640x640 (YOLO v8 standard)
      final resized = img.copyResize(
        image,
        width: inputSize,
        height: inputSize,
        interpolation: img.Interpolation.linear,
      );

      print('Resized image size: ${resized.width}x${resized.height}');

      // Convert to Float32List for model input
      // YOLO v8 expects input in format: [1, 640, 640, 3] with values normalized to [0, 1]
      final input = Float32List(1 * inputSize * inputSize * 3);
      int pixelIndex = 0;

      for (int y = 0; y < inputSize; y++) {
        for (int x = 0; x < inputSize; x++) {
          final pixel = resized.getPixel(x, y);
          
          // Extract RGB values using the image package methods
          final r = pixel.r; // Red channel
          final g = pixel.g; // Green channel
          final b = pixel.b; // Blue channel
          
          // Normalize to [0, 1] range
          input[pixelIndex++] = r / 255.0; // Red
          input[pixelIndex++] = g / 255.0; // Green
          input[pixelIndex++] = b / 255.0; // Blue
        }
      }

      print('Preprocessed input size: ${input.length}');
      print('Input range: ${input.reduce((a, b) => a < b ? a : b)} to ${input.reduce((a, b) => a > b ? a : b)}');

      return input;
    } catch (e) {
      print('Error in image preprocessing: $e');
      throw Exception('Error preprocessing image: $e');
    }
  }

  // Alternative preprocessing method that might work better with some models
  static Future<Float32List> preprocessImageAlternative(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize to 640x640
      final resized = img.copyResize(
        image,
        width: inputSize,
        height: inputSize,
        interpolation: img.Interpolation.linear,
      );

      // Convert to Float32List with different normalization
      final input = Float32List(1 * inputSize * inputSize * 3);
      int pixelIndex = 0;

      for (int y = 0; y < inputSize; y++) {
        for (int x = 0; x < inputSize; x++) {
          final pixel = resized.getPixel(x, y);
          
          // Extract RGB values using the image package methods
          final r = pixel.r;
          final g = pixel.g;
          final b = pixel.b;
          
          // Some models expect values in [-1, 1] range instead of [0, 1]
          input[pixelIndex++] = (r / 127.5) - 1.0; // Red
          input[pixelIndex++] = (g / 127.5) - 1.0; // Green
          input[pixelIndex++] = (b / 127.5) - 1.0; // Blue
        }
      }

      return input;
    } catch (e) {
      print('Error in alternative image preprocessing: $e');
      throw Exception('Error preprocessing image: $e');
    }
  }

  static List<double> postProcessOutput(List<double> output, double confidenceThreshold) {
    final List<double> filteredOutput = [];
    
    // YOLO v8 output format: [x, y, w, h, confidence, class_scores...]
    // For 4 classes (glass, paper, metal, plastic), each detection has 8 values
    // 4 (bbox) + 1 (confidence) + 4 (class scores) = 9 values per detection
    
    final valuesPerDetection = 9; // 4 bbox + 1 conf + 4 classes
    
    for (int i = 0; i < output.length; i += valuesPerDetection) {
      if (i + valuesPerDetection <= output.length) {
        final confidence = output[i + 4];
        
        if (confidence > confidenceThreshold) {
          // Add the detection to filtered output
          filteredOutput.addAll(output.sublist(i, i + valuesPerDetection));
        }
      }
    }

    return filteredOutput;
  }

  static Map<String, dynamic> getWasteTypeAndConfidence(List<double> detection) {
    // Assuming the first 5 values are [x, y, w, h, confidence]
    final confidence = detection[4];
    
    // Get class scores (skip the first 5 values)
    final classScores = detection.sublist(5);
    
    // Find the class with highest score
    int maxIndex = 0;
    double maxScore = classScores[0];
    
    for (int i = 1; i < classScores.length; i++) {
      if (classScores[i] > maxScore) {
        maxScore = classScores[i];
        maxIndex = i;
      }
    }

    // Map class index to waste type using the correct order from YOLO model
    // names: ['glass', 'metal', 'paper', 'plastic']
    final wasteTypes = ['glass', 'metal', 'paper', 'plastic'];
    final wasteType = maxIndex < wasteTypes.length ? wasteTypes[maxIndex] : 'unknown';

    return {
      'wasteType': wasteType,
      'confidence': confidence * maxScore, // Combined confidence
    };
  }

  // Helper method to reshape input tensor for YOLO v8
  static List<List<List<List<double>>>> reshapeInput(Float32List input, List<int> shape) {
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
  }

  // Method to handle YOLO v8 specific output processing
  static List<Map<String, dynamic>> processYoloV8Output(List<double> output, double confidenceThreshold) {
    final List<Map<String, dynamic>> detections = [];
    
    // YOLO v8 output format: [x, y, w, h, confidence, class_scores...]
    final valuesPerDetection = 9; // 4 bbox + 1 conf + 4 classes
    
    for (int i = 0; i < output.length; i += valuesPerDetection) {
      if (i + valuesPerDetection <= output.length) {
        final bbox = output.sublist(i, i + 4); // x, y, w, h
        final confidence = output[i + 4];
        final classScores = output.sublist(i + 5, i + valuesPerDetection);
        
        // Find the class with highest score
        int maxIndex = 0;
        double maxScore = classScores[0];
        
        for (int j = 1; j < classScores.length; j++) {
          if (classScores[j] > maxScore) {
            maxScore = classScores[j];
            maxIndex = j;
          }
        }
        
        final combinedConfidence = confidence * maxScore;
        
        if (combinedConfidence > confidenceThreshold) {
          final wasteTypes = ['glass', 'metal', 'paper', 'plastic'];
          final wasteType = maxIndex < wasteTypes.length ? wasteTypes[maxIndex] : 'unknown';
          
          detections.add({
            'wasteType': wasteType,
            'confidence': combinedConfidence,
            'boundingBox': bbox,
            'classIndex': maxIndex,
          });
        }
      }
    }
    
    // Sort by confidence (highest first)
    detections.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));
    
    return detections;
  }
}