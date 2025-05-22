import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/Indivisual/domian/entity/rewards.dart';
import 'package:greenloop/src/profile/Indivisual/domian/entity/user_rewards.dart';

abstract class RewardsRepo {
  const RewardsRepo();

ResultFuture<void> redeemReward({
    required String userId,
    required String rewardId,
  });

  ResultFuture<List<Rewards>> fetchAvailableRewards();
  ResultFuture<List<UserRewards>> fetchUserRedeemedRewards(String userId);
}