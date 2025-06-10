import 'package:dartz/dartz.dart';
import 'package:greenloop/core/errors/exceptions.dart';
import 'package:greenloop/core/errors/failure.dart';
import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/recycling/data/datasource/recycling_remote_data_source.dart';
import 'package:greenloop/src/profile/recycling/domain/entity/recycling_user.dart';
import 'package:greenloop/src/profile/recycling/domain/repos/recycling_user_repo.dart';

class RecyclingUserRepoImpl implements RecyclingUserRepo {
  final RecyclingRemoteDataSource remoteDataSource;

  const RecyclingUserRepoImpl(this.remoteDataSource);

  @override
  ResultFuture<Recycling_User> fetchUserProfile(String userId) async {
    try {
      final result = await remoteDataSource.fetchUserProfile(userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode.toString()));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: '500',
      ));
    }
  }

  @override
  ResultFuture<Recycling_User> updateUserProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await remoteDataSource.updateUserProfile(
        userId: userId,
        updates: data,
      );
      // Fetch the updated profile after update
      final updatedProfile = await remoteDataSource.fetchUserProfile(userId);
      return Right(updatedProfile);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode.toString()));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: '500',
      ));
    }
  }
}