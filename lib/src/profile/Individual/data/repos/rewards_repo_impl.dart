import 'package:dartz/dartz.dart';

import 'package:greenloop/core/errors/exceptions.dart';
import 'package:greenloop/core/errors/failure.dart';
import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/Individual/domian/entity/rewards.dart';
import 'package:greenloop/src/profile/Individual/domian/entity/user_rewards.dart';
import 'package:greenloop/src/profile/Individual/domian/repos/rewards_repo.dart'; 
import 'package:greenloop/src/profile/Individual/data/datasourves/rewards_remote_data_source.dart';

class RewardsRepoImpl implements RewardsRepo {
  final RewardsRemoteDataSource _remoteDataSource;

  const RewardsRepoImpl(this._remoteDataSource);

  @override
  ResultFuture<List<Rewards>> fetchAvailableRewards() async {
    try {
      final result = await _remoteDataSource.fetchAvailableRewards();
      return Right(result);
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

  @override
  ResultFuture<List<UserRewards>> fetchUserRedeemedRewards(String userId) async {
    try {
      final result = await _remoteDataSource.fetchUserRedeemedRewards(userId);
      return Right(result);
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

  @override
  ResultFuture<void> redeemReward({
    required String userId,
    required String rewardId,
  }) async {
    try {
      await _remoteDataSource.redeemReward(userId: userId, rewardId: rewardId);
      return const Right(null);
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