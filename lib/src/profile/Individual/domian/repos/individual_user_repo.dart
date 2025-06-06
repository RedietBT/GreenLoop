import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/Individual/domian/entity/individual_user.dart';

abstract class IndividualUserRepo {
  const IndividualUserRepo();

ResultFuture<Individual_User> fetchUserProfile(String userId);

ResultFuture<void> updateUserProfile(
    String userId, {
    required Map<String, dynamic> data, // Pass update fields as a map
  });
}