import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/Business/domain/entity/business_user.dart';
abstract class BusinessRepo {
  const BusinessRepo();

ResultFuture<Business> fetchUserProfile(String userId);

 ResultFuture<Business> updateUserProfile(
    String userId, {
    required Map<String, dynamic> data,
  });
}