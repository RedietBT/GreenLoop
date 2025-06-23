import 'package:dartz/dartz.dart';
import 'package:greenloop/core/errors/exceptions.dart';
import 'package:greenloop/core/errors/failure.dart';
import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/Individual/data/datasourves/individual_user_remot_data_sorce.dart';
import 'package:greenloop/src/profile/Individual/domian/entity/individual_user.dart';
import 'package:greenloop/src/profile/Individual/domian/repos/individual_user_repo.dart';

class IndividualUserRepoImpl implements IndividualUserRepo{

  final IndividualUserRemoteDataSource remoteDataSource;

 const IndividualUserRepoImpl(this.remoteDataSource);

  @override
  ResultFuture<Individual_User> fetchUserProfile(String userId) async {
    try {
      final user = await remoteDataSource.fetchUserProfile(userId);
      return Right(user); 
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode.toString(),
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: '500',
      ));
    }
  }

@override
  ResultFuture<Individual_User> updateUserProfile(
    String userId, {
    required Map<String, dynamic> data,
  }) async {
    try {
      await remoteDataSource.updateUserProfile(
        userId,
        data: data,
      );
      final updatedUser = await remoteDataSource.fetchUserProfile(userId);
      return Right(updatedUser);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode.toString(),
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: '500',
      ));
    }
  }
}