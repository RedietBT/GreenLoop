import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:greenloop/core/errors/exceptions.dart';
import 'package:greenloop/src/profile/Business/data/model/business_model.dart';


abstract class BusinessRemoteDataSource {
  const BusinessRemoteDataSource();

  Future<BusinessModel> fetchUserProfile(String userId);

  Future<BusinessModel> updateUserProfile(
    String userId, {
    required Map<String, dynamic> data,
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
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<BusinessModel> updateUserProfile( 
    String userId, {
    required Map<String, dynamic> data,
  }) async {
    try {
      final Map<String, dynamic> dataToSend = Map.from(data);

      await _supabaseClient
          .from('business')
          .update(dataToSend) 
          .eq('id', userId)
          .select()
          .single();

      // Always fetch the updated profile after update
      final updatedProfile = await fetchUserProfile(userId);
      return updatedProfile;
    } on PostgrestException catch (e) {
      print('Postgrest error updating business profile: ${e.message}, Code: ${e.code}');
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.code ?? '') ?? 500,
      );
    } catch (e) {
      print('Unexpected error updating business profile: $e');
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }
}