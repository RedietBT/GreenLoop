import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:greenloop/core/errors/failure.dart';
import 'package:greenloop/core/usecases/usecase.dart';
import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/waste_detection/domain/entity/waste_detection_result.dart';
import 'package:greenloop/src/waste_detection/domain/repos/waste_detection_repo.dart';

class DetectWasteUseCase implements UsecaseWithParams<WasteDetectionResult, File> {
  final WasteDetectionRepo _repo;

  const DetectWasteUseCase(this._repo);

  @override
  ResultFuture<WasteDetectionResult> call(File params) async {
    return await _repo.detectWaste(params);
  }
} 