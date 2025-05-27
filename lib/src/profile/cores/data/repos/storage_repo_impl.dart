import 'dart:io'; 
import 'package:dartz/dartz.dart';
import 'package:greenloop/core/errors/exceptions.dart';
import 'package:greenloop/core/errors/failure.dart';
import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/cores/data/dataSource/storage_remote_data_source.dart';
import 'package:greenloop/src/profile/cores/domain/repos/storage_repo.dart';


class StorageRepoImpl implements StorageRepo {
  final StorageRemoteDataSource _remoteDataSource;

  const StorageRepoImpl(this._remoteDataSource);

  @override
  ResultFuture<String> uploadFile({
    required String bucketName,
    String? filepath,
    required File file,
  }) async {
    try {
      final String publicUrl = await _remoteDataSource.uploadFile(
        bucketName: bucketName,
        filePath: filepath,
        file: file,
      );
      return Right(publicUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: '500',
      )
      );
    }
  }
}