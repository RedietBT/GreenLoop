import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:greenloop/core/errors/exceptions.dart';
import 'package:greenloop/src/profile/Business/data/model/business_model.dart'; // Corrected import path for model

abstract class BusinessRemoteDataSource {
  const BusinessRemoteDataSource();

  Future<BusinessModel> fetchUserProfile(String userId);
  Future<void> updateUserProfile({
    required String userId,
    required String business_name,
    required String contact_person_first_name,
    required String contact_person_last_name,
    required String phone_number,
    required String? address,
    required String email,
    required String? avatarUrl,
    required String? points,
    required String? description,
  });
}

class BusinessRemoteDataSourceImpl implements BusinessRemoteDataSource {

  final SupabaseClient _supabaseClient;

  const BusinessRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<BusinessModel> fetchUserProfile(String userId) async {
    try {
      print('Fetching business profile for user ID: $userId');
      final response = await _supabaseClient
          .from('business') 
          .select()
          .eq('id', userId)
          .single(); // Expecting a single record
      print('Business profile response: $response');
      return BusinessModel.fromJson(response);
    } on PostgrestException catch (e) {
      print('Postgrest error fetching business profile: ${e.message}');
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.code ?? '') ?? 500, 
      );
    } catch (e) {
      print('Unexpected error fetching business profile: $e');
      // Catch any other unexpected errors during the process.
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<void> updateUserProfile({
     required String userId,
     String? business_name,
     String? contact_person_first_name,
     String? contact_person_last_name,
     String? phone_number,
     String? address,
     String? email,
     String? avatarUrl,
     String? points,
     String? description,
  }) async {
    try {
      // Prepare a map of updates. The keys here should match your Supabase column names.
      final Map<String, dynamic> updates = {
        'business_name': business_name,
        'contact_person_first_name': contact_person_first_name,
        'contact_person_last_name': contact_person_last_name,
        'phone': phone_number,
        'email': email,
        'description': description ?? '',
        'address': address ?? '', // Assuming address can be an empty string
      };

      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (points != null) updates['points'] = points;
      await _supabaseClient
          .from('business') 
          .update(updates)
          .eq('id', userId);
    } on PostgrestException catch (e) {
      
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.code ?? '') ?? 500,
      );
    } catch (e) {
      
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }
}
