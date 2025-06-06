
import 'package:greenloop/src/profile/Individual/data/model/indivisual_user_model.dart';
import 'package:greenloop/src/profile/Individual/domian/entity/individual_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:greenloop/core/errors/exceptions.dart';



abstract class IndividualUserRemoteDataSource { 
  const IndividualUserRemoteDataSource();

  Future<Individual_User> fetchUserProfile(String userId);

  Future<void> updateUserProfile(
    String userId, {
    required Map<String, dynamic> data, 
  });
}

class IndividualUserRemoteDataSourceImpl implements IndividualUserRemoteDataSource {
  final SupabaseClient _supabaseClient;

  const IndividualUserRemoteDataSourceImpl(this._supabaseClient);

@override
  Future<Individual_User> fetchUserProfile(String userId) async {
    try {
      final dynamic responseData = await _supabaseClient
          .from('profile') // Your table name
          .select()
          .eq('id', userId)
          .single(); // Supabase .single() returns dynamic, which can be Map<String, dynamic> or null

      // Handle null response (user not found)
      if (responseData == null) {
        throw ServerException(
          message: 'User profile data not found for ID: $userId',
          statusCode: 404, // HTTP 404 Not Found
        );
      }

      // CRITICAL FIX: Explicitly cast the dynamic responseData to Map<String, dynamic>
      // This directly addresses the "Map<dynamic, dynamic>" error.
      if (responseData is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'Invalid data format received from server. Expected Map<String, dynamic>.',
          statusCode: 500, // Internal Server Error, or appropriate error code
        );
      }

      // Now responseData is guaranteed to be Map<String, dynamic> and non-null
      return Individual_UserModel.fromJson(responseData);

    } on PostgrestException catch (e) {
      // Catch Supabase-specific errors
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.code ?? '') ?? 500, // Supabase error codes
      );
    } catch (e) {
      // Catch any other unexpected errors
      throw ServerException(
        message: e.toString(), // Convert other exceptions to string message
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> updateUserProfile(
    String userId, {
    required Map<String, dynamic> data, // Corrected signature here too
  }) async {
    try {
      // Directly use the 'data' map passed in, no need for manual construction
      await _supabaseClient
          .from('profile') // Assuming your user data is in a 'profile' table
          .update(data)    // Pass the map directly to Supabase update
          .eq('id', userId)
          .single(); // Use .single() if you expect only one row for a given userId
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