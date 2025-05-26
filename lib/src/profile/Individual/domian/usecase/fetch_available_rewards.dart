import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/Individual/domian/entity/rewards.dart';
import 'package:greenloop/src/profile/Individual/domian/repos/rewards_repo.dart';

class FetchAvailableRewards {
  final RewardsRepo repository;
  
  const FetchAvailableRewards(this.repository);

  ResultFuture<List<Rewards>> call() {
    return repository.fetchAvailableRewards();
  }
}