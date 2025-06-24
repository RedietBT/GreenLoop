import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:greenloop/core/errors/failure.dart';
import 'package:greenloop/core/usecases/usecase.dart';
import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/waste_detection/domain/repos/waste_detection_repo.dart';

class PickImageUseCase implements UsecaseWithParams<File?, ImageSource> {
  final WasteDetectionRepo _repo;

  const PickImageUseCase(this._repo);

  @override
  ResultFuture<File?> call(ImageSource params) async {
    return await _repo.pickImage(params);
  }
} 