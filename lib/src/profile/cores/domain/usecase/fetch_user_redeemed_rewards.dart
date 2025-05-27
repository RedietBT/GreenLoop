import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/cores/domain/entity/user_rewards.dart';
import 'package:greenloop/src/profile/cores/domain/repos/rewards_repo.dart';

class FetchUserRedeemedRewards {
  final RewardsRepo repository;

  const FetchUserRedeemedRewards(this.repository);
  ResultFuture<List<UserRewards>> call(String userId) {
    return repository.fetchUserRedeemedRewards(userId);
  }
}