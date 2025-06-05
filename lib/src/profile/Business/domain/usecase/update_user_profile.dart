import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/Business/domain/repo/business_repo.dart';

class UpdateUserProfile {
  final BusinessRepo businessRepo;
  const UpdateUserProfile(this.businessRepo);
  ResultFuture<void> call(
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
  }) {
    return businessRepo.updateUserProfile(
      userId,
      business_name: business_name,
      contact_person_first_name: contact_person_first_name,
      contact_person_last_name: contact_person_last_name,
      phone_number: phone_number,
      address: address,
      email: email,
      avatarUrl: avatarUrl,
      points: points,
      description: description,
    );
  }
}