import 'package:supabase_flutter/supabase_flutter.dart';

abstract class RegisterNewUserRemoteDataSource {
  Future<void> insertUserProfile(String id, String firstName, String lastName, String email, String? role);
  Future<void> insertIntoRecyclingTable(String id, String centerName, String contactInfo, String email, String? role);
  Future<void> insertIntoBusinessTable(String id, String businessName, String contactPersonFirstName, String contactPersonLastName, String email, String phoneNo, String? role);
}

class RegisterNewUserRemoteDataSourceImpl implements RegisterNewUserRemoteDataSource {
  final SupabaseClient client;

  const RegisterNewUserRemoteDataSourceImpl(this.client);

  @override
  Future<void> insertUserProfile(String id, String firstName, String lastName, String email, String? role) async {
    try {
      await client.from('profile').insert({
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'role': role,
      });
    } catch (e) {
      throw Exception('Failed to insert user profile: $e');
    }
  }

  @override
  Future<void> insertIntoRecyclingTable(String id, String centerName, String contactInfo, String email, String? role) async {
    try {
      await client.from('recycling_center').insert({
        'id': id,
        'center_name': centerName,
        'contact': contactInfo,
        'email': email,
        'role': role,
      });
    } catch (e) {
      throw Exception('Failed to insert into recycling table: $e');
    }
  }
  @override
  Future<void> insertIntoBusinessTable(String id, String businessName, String contactPersonFirstName, String contactPersonLastName, String email, String phoneNo, String? role) async {
    try {
      await client.from('business').insert({
        'id': id,
        'business_name': businessName,
        'contact_person_first_name': contactPersonFirstName,
        'contact_person_last_name': contactPersonLastName,
        'email': email,
        'phone_no': phoneNo,
        'role': role,
      });
    } catch (e) {
      throw Exception('Failed to insert into business table: $e');
    }
  }
}
