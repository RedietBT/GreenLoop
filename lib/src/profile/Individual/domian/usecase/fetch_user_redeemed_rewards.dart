import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/Individual/domian/entity/user_rewards.dart';
import 'package:greenloop/src/profile/Individual/domian/repos/rewards_repo.dart';

class FetchUserRedeemedRewards {
  final RewardsRepo repository;

  const FetchUserRedeemedRewards(this.repository);
  ResultFuture<List<UserRewards>> call(String userId) {
    return repository.fetchUserRedeemedRewards(userId);
  }
}