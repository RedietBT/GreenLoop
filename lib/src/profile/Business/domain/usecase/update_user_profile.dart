import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/Business/domain/entity/business_user.dart';
import 'package:greenloop/src/profile/Business/domain/repo/business_repo.dart';

class UpdateUserProfile {
final BusinessRepo repository;

  const UpdateUserProfile(this.repository);

  ResultFuture<Business> call(String userId, Map<String, dynamic> data) {
    return repository.updateUserProfile(userId, data: data);
  }
}