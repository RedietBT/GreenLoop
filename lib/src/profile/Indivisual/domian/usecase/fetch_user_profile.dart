import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/Indivisual/domian/entity/individual_user.dart';
import 'package:greenloop/src/profile/Indivisual/domian/repos/individual_user_repo.dart';

class FetchUserProfile {
  final IndividualUserRepo repository;

 const FetchUserProfile(this.repository);

  ResultFuture<Individual_User> call(String userId) {
    return repository.fetchUserProfile(userId);
  }
}