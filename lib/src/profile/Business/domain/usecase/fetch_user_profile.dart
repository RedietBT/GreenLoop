import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/Business/domain/entity/business_user.dart';
import 'package:greenloop/src/profile/Business/domain/repo/business_repo.dart';

class FetchUserProfile {
  final BusinessRepo businessRepo;
  const FetchUserProfile(this.businessRepo);
  ResultFuture<Business> call (String userId)
  {
    return businessRepo.fetchUserProfile(userId);
  }
}