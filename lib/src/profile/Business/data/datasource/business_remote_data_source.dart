import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:greenloop/core/errors/exceptions.dart';
import 'package:greenloop/src/profile/Business/data/model/business_model.dart';
import 'package:greenloop/src/profile/Business/domain/entity/business_user.dart';

abstract class BusinessRemoteDataSource {
  const BusinessRemoteDataSource();

  Future<BusinessModel> fetchUserProfile(String userId);

  Future<void> updateUserProfile(
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
      // Catch any other unexpected errors during the process.
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

   @override
  Future<Business> updateUserProfile(
    String userId, {
    required Map<String, dynamic> data,
  }) async {
    try {
      final dynamic responseData = await _supabaseClient
          .from('business')
          .update(data)  
          .eq('id', userId)
          .select()
          .single(); 

          if (responseData == null) {
         throw ServerException(
          message: 'User profile not found for update with ID: $userId',
          statusCode: 404,
        );
      }

      if (responseData is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'Invalid data format received after update. Expected Map<String, dynamic>.',
          statusCode: 500,
        );
      }

      return BusinessModel.fromJson(responseData);
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
