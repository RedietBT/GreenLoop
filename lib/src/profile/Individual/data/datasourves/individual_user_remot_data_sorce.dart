
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
          .single(); 
      if (responseData == null) {
        throw ServerException(
          message: 'User profile data not found for ID: $userId',
          statusCode: 404,
        );
      }

      if (responseData is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'Invalid data format received from server. Expected Map<String, dynamic>.',
          statusCode: 500, 
        );
      }

      return Individual_UserModel.fromJson(responseData);

    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.code ?? '') ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: e.toString(), 
        statusCode: 500,
      );
    }
  }

  @override
  Future<Individual_User> updateUserProfile(
    String userId, {
    required Map<String, dynamic> data,
  }) async {
    try {
      final dynamic responseData = await _supabaseClient
          .from('profile')
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

      return Individual_UserModel.fromJson(responseData);
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