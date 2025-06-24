import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:greenloop/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/waste_detection/domain/entity/waste_detection_result.dart';

abstract class WasteDetectionRepo {
  const WasteDetectionRepo();

  ResultFuture<File?> pickImage(ImageSource source);
  ResultFuture<WasteDetectionResult> detectWaste(File image);
} 