import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/cores/domain/repos/rewards_repo.dart';

class RedeemReward {
  final RewardsRepo repository;

 const RedeemReward(this.repository);
 
 ResultFuture<void> call(String userId, String rewardId) {
    return repository.redeemReward(userId: userId, rewardId: rewardId);
  }
}