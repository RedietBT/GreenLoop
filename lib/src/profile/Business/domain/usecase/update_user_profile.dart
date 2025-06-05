import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/Business/domain/repo/business_repo.dart';

class UpdateUserProfile {
  final BusinessRepo businessRepo;
  const UpdateUserProfile(this.businessRepo);
  ResultFuture<void> call(
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
  }) {
    return businessRepo.updateUserProfile(
      userId,
      business_name: business_name,
      contact_person_first_name: contact_person_first_name,
      contact_person_last_name: contact_person_last_name,
      phone_number: phone_number,
      role: role,
      address: address,
      email: email,
      avatarUrl: avatarUrl,
      points: points,
      description: description,
    );
  }
}