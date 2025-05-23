import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/auth/domain/entity/individual_user.dart';
import 'package:greenloop/src/profile/Indivisual/domian/repos/individual_user_repo.dart';

class FetchUserProfile {
  final IndividualUserRepo repository;

  FetchUserProfile(this.repository);

  ResultFuture<IndividualUser> call(String userId) {
    return repository.fetchUserProfile(userId);
  }
}