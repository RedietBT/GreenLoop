import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/Individual/domian/entity/individual_user.dart';
import 'package:greenloop/src/profile/Individual/domian/repos/individual_user_repo.dart';

class UpdateUserProfile {
  final IndividualUserRepo repository;

  const UpdateUserProfile(this.repository);

  ResultFuture<Individual_User> call(String userId, Map<String, dynamic> data) {
    return repository.updateUserProfile(userId, data: data);
  }
}