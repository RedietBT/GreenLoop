import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/Individual/domian/repos/individual_user_repo.dart';

class UpdateUserProfile {
  final IndividualUserRepo repository;

  const UpdateUserProfile(this.repository);
  
  ResultFuture<void> call(String userId, String? firstName, String? lastname, String? email, String? avatarUrl, String? points, String? description) {
    return repository.updateUserProfile(userId, firstName: firstName, lastName: lastname, email: email, avatarUrl: avatarUrl, points: points, description: description);
  }
}