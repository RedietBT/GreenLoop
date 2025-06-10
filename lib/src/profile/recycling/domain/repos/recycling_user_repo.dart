import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/recycling/domain/entity/recycling_user.dart';

abstract class RecyclingUserRepo {
  const RecyclingUserRepo();

  ResultFuture<Recycling_User> fetchUserProfile(String userId);

  ResultFuture<Recycling_User> updateUserProfile({
    required String userId,
    required Map<String, dynamic> data,
  });
} 