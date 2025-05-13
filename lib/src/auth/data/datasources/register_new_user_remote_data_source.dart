import 'package:supabase_flutter/supabase_flutter.dart';

abstract class RegisterNewUserRemoteDataSource {
  Future<void> insertUserProfile(String id, String firstName, String lastName, String email, String? role);
  Future<void> insertIntoRecyclingTable(String id, String centerName, String contactInfo, String email, String? role);
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
}
