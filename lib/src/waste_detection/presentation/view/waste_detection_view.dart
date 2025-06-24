import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:greenloop/core/services/injection_container.dart';
import '../cubits/waste_detection_cubit.dart';
import '../widgets/waste_detection_result.dart';
import 'dart:io';
import 'package:greenloop/core/services/gemini_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class WasteDetectionView extends StatefulWidget {
  const WasteDetectionView({super.key});

  @override
  State<WasteDetectionView> createState() => _WasteDetectionViewState();
}

class _WasteDetectionViewState extends State<WasteDetectionView> {
  Map<String, dynamic>? geminiResult;
  bool geminiLoading = false;
  String? geminiError;
  String detectionMethod = 'local'; // 'local' or 'gemini'

  Future<File?> _pickAndCompressImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile == null) return null;
    final imageFile = File(pickedFile.path);
    // Compress image for Gemini
    final compressed = await FlutterImageCompress.compressWithFile(
      imageFile.absolute.path,
      minWidth: 512,
      minHeight: 512,
      quality: 70,
      format: CompressFormat.jpeg,
    );
    if (compressed == null) return null;
    final tempDir = Directory.systemTemp;
    final compressedFile = await File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg').writeAsBytes(compressed);
    return compressedFile;
  }

  void _onPickImage(BuildContext context, ImageSource source) async {
    if (detectionMethod == 'local') {
      context.read<WasteDetectionCubit>().captureImage(source);
    } else {
      setState(() {
        geminiLoading = true;
        geminiError = null;
        geminiResult = null;
      });
      final compressedFile = await _pickAndCompressImage(source);
      if (compressedFile == null) {
        setState(() {
          geminiError = 'No image selected or compression failed.';
          geminiLoading = false;
        });
        return;
      }
      try {
        final gemini = GeminiService('AIzaSyBf0cp0p9ylk8tjr7Hj-Dr55N2bogM80Tk');
        final result = await gemini.classifyWasteWithGemini(compressedFile);
        setState(() {
          geminiResult = result;
          geminiLoading = false;
        });
      } catch (e) {
        setState(() {
          if (e.toString().contains('429')) {
            geminiError = 'Gemini API quota exceeded. Please try again later or use the local model.';
          } else {
            geminiError = e.toString();
          }
          geminiLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WasteDetectionCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Waste Detection'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocBuilder<WasteDetectionCubit, WasteDetectionState>(
          builder: (context, state) {
            if (geminiLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (geminiResult != null) {
              return _buildGeminiResultCard();
            }
            if (state is WasteDetectionLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Analyzing waste...',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please wait while we identify the waste type',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }
            if (state is WasteDetectionSuccess) {
              return Column(
                children: [
                  Expanded(
                    child: WasteDetectionResultWidget(result: state.result),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            geminiResult = null;
                            geminiError = null;
                            geminiLoading = false;
                          });
                          context.read<WasteDetectionCubit>().reset();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Scan Another Item'),
                      ),
                    ),
                  ),
                ],
              );
            }
            if (state is WasteDetectionError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          geminiResult = null;
                          geminiError = null;
                          geminiLoading = false;
                        });
                        _onPickImage(context, ImageSource.camera);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }
            return _buildInitialView(context);
          },
        ),
      ),
    );
  }

  Widget _buildInitialView(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.green, Colors.lightGreen],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ToggleButtons(
                  isSelected: [detectionMethod == 'local', detectionMethod == 'gemini'],
                  onPressed: (index) {
                    setState(() {
                      detectionMethod = index == 0 ? 'local' : 'gemini';
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  selectedColor: Colors.white,
                  fillColor: Colors.green,
                  color: Colors.green,
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Local Model'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Gemini AI'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    detectionMethod == 'local' ? Icons.camera_alt : Icons.auto_awesome,
                    size: 80,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  detectionMethod == 'local' ? 'Scan Your Waste' : 'Gemini AI Waste Scan',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  detectionMethod == 'local'
                      ? 'Take a photo or choose from gallery to identify waste type'
                      : 'Take a photo or choose from gallery to let Gemini AI analyze your waste and give sorting steps!',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _onPickImage(context, ImageSource.camera),
                    icon: Icon(detectionMethod == 'local' ? Icons.camera_alt : Icons.auto_awesome),
                    label: Text(detectionMethod == 'local' ? 'Take Photo' : 'Take Photo (Gemini)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _onPickImage(context, ImageSource.gallery),
                    icon: Icon(detectionMethod == 'local' ? Icons.photo_library : Icons.auto_awesome),
                    label: Text(detectionMethod == 'local' ? 'Choose from Gallery' : 'Choose from Gallery (Gemini)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (geminiError != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Gemini error: $geminiError', style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGeminiResultCard() {
    final result = geminiResult!;
    List<String> steps = [];
    if (result['sorting_steps'] is List) {
      steps = List<String>.from(result['sorting_steps']);
    } else if (result['sorting_steps'] != null) {
      steps = result['sorting_steps'].toString().split(RegExp(r'\d+\.'));
      steps.removeWhere((e) => e.trim().isEmpty);
    }
    return Container(
      color: Colors.green.shade50,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.green, size: 36),
                      const SizedBox(width: 12),
                      Text(
                        'Gemini AI Result',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Class: ${result['class'] ?? 'Unknown'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Recyclable: ${result['recyclable'] == true ? 'Yes' : 'No'}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  Text('Sorting Steps:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ...steps.map((step) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 16)),
                            Expanded(child: Text(step.trim(), style: const TextStyle(fontSize: 16))),
                          ],
                        ),
                      )),
                  const SizedBox(height: 12),
                  if (result['points'] != null)
                    Row(
                      children: [
                        const Icon(Icons.emoji_events, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text('You earned ${result['points']} points!', style: const TextStyle(fontSize: 16, color: Colors.orange)),
                      ],
                    ),
                  if (result['encouragement'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(result['encouragement'], style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.blue)),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          geminiResult = null;
                          geminiError = null;
                          geminiLoading = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Scan Another Item'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 