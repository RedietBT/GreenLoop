import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/recycling/domain/entity/recycling_user.dart';
import 'package:greenloop/src/profile/recycling/domain/repos/recycling_user_repo.dart';

class FetchRecyclingUserProfile {
  final RecyclingUserRepo repository;

  FetchRecyclingUserProfile(this.repository);

  ResultFuture<Recycling_User> call(String userId) {
    return repository.fetchUserProfile(userId);
  }
} 