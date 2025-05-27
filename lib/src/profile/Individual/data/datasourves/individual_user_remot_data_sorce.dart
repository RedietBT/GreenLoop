
import 'package:greenloop/src/profile/Individual/data/model/indivisual_user_model.dart';
import 'package:greenloop/src/profile/Individual/domian/entity/individual_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:greenloop/core/errors/exceptions.dart';



abstract class IndividualUserRemoteDataSource { 
  const IndividualUserRemoteDataSource();

  Future<Individual_User> fetchUserProfile(String userId);

  Future<void> updateUserProfile(
    String userId, {
    required String firstName,
    required String lastName,
    required String email,
    required String? avatarUrl,
    required String? points,
  });
}

class IndividualUserRemoteDataSourceImpl implements IndividualUserRemoteDataSource {
  final SupabaseClient _supabaseClient;

  const IndividualUserRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<Individual_User> fetchUserProfile(String userId) async {
    try {
      final response = await _supabaseClient
          .from('profile')
          .select()
          .eq('id', userId)
          .single();

      return Individual_UserModel.fromJson(response);
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
  Future<void> updateUserProfile(
    String userId, {
    required String firstName,
    required String lastName,
    required String email,
    required String? avatarUrl,
    required String? points,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
      };
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (points != null) updates['points'] = points;

      await _supabaseClient
          .from('profile')
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