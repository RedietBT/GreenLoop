import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entity/waste_detection_result.dart';
import '../../domain/usecases/detect_waste_usecase.dart';
import '../../domain/usecases/pick_image_usecase.dart';

// States
abstract class WasteDetectionState extends Equatable {
  const WasteDetectionState();

  @override
  List<Object> get props => [];
}

class WasteDetectionInitial extends WasteDetectionState {}

class WasteDetectionLoading extends WasteDetectionState {}

class WasteDetectionSuccess extends WasteDetectionState {
  final WasteDetectionResult result;

  const WasteDetectionSuccess(this.result);

  @override
  List<Object> get props => [result];
}

class WasteDetectionError extends WasteDetectionState {
  final String message;

  const WasteDetectionError(this.message);

  @override
  List<Object> get props => [message];
}

// Cubit
class WasteDetectionCubit extends Cubit<WasteDetectionState> {
  final DetectWasteUseCase _detectWasteUseCase;
  final PickImageUseCase _pickImageUseCase;

  File? _lastPickedImage;
  File? get lastPickedImage => _lastPickedImage;

  WasteDetectionCubit({
    required DetectWasteUseCase detectWasteUseCase,
    required PickImageUseCase pickImageUseCase,
  })  : _detectWasteUseCase = detectWasteUseCase,
        _pickImageUseCase = pickImageUseCase,
        super(WasteDetectionInitial());

  Future<void> captureImage(ImageSource source) async {
    try {
      final result = await _pickImageUseCase(source);
      result.fold(
        (failure) => emit(WasteDetectionError(failure.message)),
        (image) {
          if (image != null) {
            _lastPickedImage = image;
            processImage(image);
          }
        },
      );
    } catch (e) {
      emit(WasteDetectionError(e.toString()));
    }
  }

  Future<void> processImage(File image) async {
    emit(WasteDetectionLoading());
    try {
      final result = await _detectWasteUseCase(image);
      result.fold(
        (failure) => emit(WasteDetectionError(failure.message)),
        (detectionResult) => emit(WasteDetectionSuccess(detectionResult)),
      );
    } catch (e) {
      emit(WasteDetectionError(e.toString()));
    }
  }

  void reset() {
    _lastPickedImage = null;
    emit(WasteDetectionInitial());
  }
} 