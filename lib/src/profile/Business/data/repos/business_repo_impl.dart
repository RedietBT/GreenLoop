import 'package:dartz/dartz.dart'; // For Either (Right and Left)
import 'package:greenloop/core/errors/exceptions.dart'; // For ServerException
import 'package:greenloop/core/errors/failure.dart';
import 'package:greenloop/core/utils/typedefs.dart'; // For ResultFuture
import 'package:greenloop/src/profile/Business/data/datasource/business_remote_data_source.dart';
import 'package:greenloop/src/profile/Business/domain/entity/business_user.dart';
import 'package:greenloop/src/profile/Business/domain/repo/business_repo.dart'; // Import the abstract repository interface

class BusinessRepoImpl implements BusinessRepo {
  final BusinessRemoteDataSource _remoteDataSource;
  const BusinessRepoImpl(this._remoteDataSource);

  @override
  ResultFuture<Business> fetchUserProfile(String userId) async {
    try {
      final result = await _remoteDataSource.fetchUserProfile(userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 500));
    }
  }

 @override
  ResultFuture<Business> updateUserProfile(
    String userId, {
    required Map<String, dynamic> data,
  }) async {
    try {
      await  _remoteDataSource.updateUserProfile(
        userId,
        data: data,
      );
      final updatedUser = await  _remoteDataSource.fetchUserProfile(userId);
      return Right(updatedUser); 
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: '500',
      ));
    }
  }
}
