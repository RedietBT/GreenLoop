import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/Individual/domian/repos/individual_user_repo.dart';

class UpdateUserProfile {
  final IndividualUserRepo repository;

  const UpdateUserProfile(this.repository);

  // The 'call' method now accepts a Map<String, dynamic> for the update data
  ResultFuture<void> call(String userId, Map<String, dynamic> data) {
    return repository.updateUserProfile(userId, data: data);
  }
}