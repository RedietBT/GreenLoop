import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/Business/domain/entity/business_user.dart';
abstract class BusinessRepo {
  const BusinessRepo();

ResultFuture<Business> fetchUserProfile(String userId);

ResultFuture<void> updateUserProfile(
  String userId, {
    required String business_name, 
    required String contact_person_first_name,
    required String contact_person_last_name,
    required String phone_number,
    required String role,
    required String? address,
    required String email,     
    required String? avatarUrl, 
    required String? points,
    required String? description,    
  });
}