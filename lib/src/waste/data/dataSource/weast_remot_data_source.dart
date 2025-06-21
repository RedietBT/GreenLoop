import 'package:greenloop/core/errors/exceptions.dart';
import 'package:greenloop/src/profile/recycling/data/model/recycling_user_model.dart';
import 'package:greenloop/src/waste/data/model/weast_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class WeastRemotDataSource {

  const WeastRemotDataSource();
  Future<void> insertWeastProfile(
     String weastId,
     String userId,
     String type,
     String quantity,
     String location,
     String requestStatus,
  );

  Future<WeastModel> updateWeastProfile({
    required String weastId,
    required Map<String, dynamic> updates,
  });

  Future<void> requestForPickup(
     String id, 
     String userId,
     String weastId,
     String recyclingCenterId,
     String requestStatus,
  );

  Future<Recycling_UserModel> fetchRecylingProfile(String recyclingId);
}

class WeastRemotDataSourceImpl implements WeastRemotDataSource {
  final SupabaseClient _supabaseClient;

  const WeastRemotDataSourceImpl(this._supabaseClient);

@override
  Future<void> insertWeastProfile(
     String weastId,
     String userId,
     String type,
     String quantity,
     String location,
     String requestStatus,
  ) async {
    try {
      await _supabaseClient.from('waste_submission').insert({
        'id': weastId,
        'userID': userId,
        'type': type,
        'quantity': quantity,
        'location': location,
        'request-status': requestStatus,
      });
    } catch (e) {
      throw Exception('Failed to insert user profile: $e');
    }
  }

  @override
  Future<WeastModel> updateWeastProfile({
    required String weastId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final dynamic response = await _supabaseClient
          .from('waste_submission')
          .update(updates)
          .eq('id', weastId)
          .select()
          .single();

        if (response == null) {
        throw ServerException(
          message: 'Recycling profile not found for update with ID: $weastId',
          statusCode: 404,
        );
      }

      if (response is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'Invalid data format received after update. Expected Map<String, dynamic>.',
          statusCode: 500,
        );
      }
      return WeastModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<void> requestForPickup(
     String id,
     String userId,
     String weastId,
     String recyclingCenterId,
     String requestStatus,
  ) async {
    try {
      await _supabaseClient.from('pickup_requests').insert({
        'id': id,
        'userID': userId,
        'weast-submissionID': weastId,
        'recycling-centerID': recyclingCenterId,
        'request-status': requestStatus,
      });
    } catch (e) {
      throw Exception('Failed to insert into recycling table: $e');
    }
  }

  @override
  Future<Recycling_UserModel> fetchRecylingProfile(String recyclingId) async {
    try {
      final dynamic response = await _supabaseClient
          .from('recycling_center')
          .select()
          .eq('id', recyclingId)
          .single();

           if (response == null) {
        throw ServerException(
          message: 'Recycling profile data not found for ID: $recyclingId',
          statusCode: 404,
        );
      }

      // Explicitly cast the dynamic responseData to Map<String, dynamic>
      if (response is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'Invalid data format received from server. Expected Map<String, dynamic>.',
          statusCode: 500,
        );
      }

      return Recycling_UserModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }
}