import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/Business/domain/entity/business_user.dart';
abstract class BusinessRepo {
  const BusinessRepo();

ResultFuture<Business> fetchUserProfile(String userId);

ResultFuture<void> updateUserProfile(
  String userId, {
     String? business_name, 
     String? contact_person_first_name,
     String? contact_person_last_name,
     String? phone_number,
     String? address,
     String? email,     
     String? avatarUrl, 
     String? points,
     String? description,    
  });
}