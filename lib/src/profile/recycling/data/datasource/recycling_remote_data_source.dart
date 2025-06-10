import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:greenloop/core/errors/exceptions.dart';
import 'package:greenloop/src/profile/recycling/data/model/recycling_user_model.dart';

abstract class RecyclingRemoteDataSource {
  const RecyclingRemoteDataSource();

  Future<Recycling_UserModel> fetchUserProfile(String userId);
  Future<Recycling_UserModel> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updates,
  });
}

class RecyclingRemoteDataSourceImpl implements RecyclingRemoteDataSource {
  final SupabaseClient _supabaseClient;

  const RecyclingRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<Recycling_UserModel> fetchUserProfile(String userId) async {
    try {
      final dynamic responseData = await _supabaseClient
          .from('recycling_center')
          .select()
          .eq('id', userId)
          .single();

      // Handle null response (user not found)
      if (responseData == null) {
        throw ServerException(
          message: 'Recycling profile data not found for ID: $userId',
          statusCode: 404,
        );
      }

      // Explicitly cast the dynamic responseData to Map<String, dynamic>
      if (responseData is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'Invalid data format received from server. Expected Map<String, dynamic>.',
          statusCode: 500,
        );
      }

      return Recycling_UserModel.fromJson(responseData);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.code ?? '') ?? 500,
      );
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<Recycling_UserModel> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final dynamic responseData = await _supabaseClient
          .from('recycling_center')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      if (responseData == null) {
        throw ServerException(
          message: 'Recycling profile not found for update with ID: $userId',
          statusCode: 404,
        );
      }

      if (responseData is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'Invalid data format received after update. Expected Map<String, dynamic>.',
          statusCode: 500,
        );
      }

      return Recycling_UserModel.fromJson(responseData);
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