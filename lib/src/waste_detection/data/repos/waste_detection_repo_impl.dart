import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dartz/dartz.dart';
import 'package:greenloop/core/errors/failure.dart';
import 'package:greenloop/core/errors/exceptions.dart';
import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/waste_detection/domain/entity/waste_detection_result.dart';
import 'package:greenloop/src/waste_detection/domain/repos/waste_detection_repo.dart';
import '../datasources/waste_detection_remote_data_source.dart';

class WasteDetectionRepoImpl implements WasteDetectionRepo {
  final WasteDetectionRemoteDataSource _remoteDataSource;

  const WasteDetectionRepoImpl(this._remoteDataSource);

  @override
  ResultFuture<File?> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      
      if (image != null) {
        return Right(File(image.path));
      }
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure.formException(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 'PICK_IMAGE_ERROR'));
    }
  }

  @override
  ResultFuture<WasteDetectionResult> detectWaste(File image) async {
    try {
      final result = await _remoteDataSource.detectWaste(image);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure.formException(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 'DETECT_WASTE_ERROR'));
    }
  }
} 