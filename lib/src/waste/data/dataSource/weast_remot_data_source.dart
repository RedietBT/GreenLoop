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

  Future<List<Recycling_UserModel>> fetchRecylingCenters(String location);
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
  ) async {
    try {
      await _supabaseClient.from('waste_submission').insert({
        'id': weastId,
        'userID': userId,
        'type': type,
        'quantity': quantity,
        'location': location,
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
        'waste-submissionID': weastId,
        'recycling-centerID': recyclingCenterId,
        'request-status': requestStatus,
      });
    } catch (e) {
      throw Exception('Failed to insert into recycling table: $e');
    }
  }

  @override
  Future<List<Recycling_UserModel>> fetchRecylingCenters(String location) async {
    try {
      print('Searching for recycling centers with location: $location');
      
      // First, try to get all recycling centers to see what's available
      final allCenters = await _supabaseClient
          .from('recycling_center')
          .select();
      
      // Try multiple search strategies
      List<Recycling_UserModel> results = [];
      
      // Strategy 1: Search by address with ilike
      try {
        final response1 = await _supabaseClient
            .from('recycling_center')
            .select()
            .ilike('address', '%${location.toLowerCase()}%');
        
        if (response1.isNotEmpty) {
          print('Strategy 1 found ${response1.length} centers');
          results = _parseRecyclingCenters(response1);
        }
      } catch (e) {
        print('Strategy 1 failed: $e');
      }
      
      if (results.isEmpty) {
        try {
          final response2 = await _supabaseClient
              .from('recycling_center')
              .select()
              .ilike('address', '%$location%');
          
          if (response2.isNotEmpty) {
            print('Strategy 2 found ${response2.length} centers');
            results = _parseRecyclingCenters(response2);
          }
        } catch (e) {
          print('Strategy 2 failed: $e');
        }
      }
      
      // Strategy 3: If still no results, try searching by center_name
      if (results.isEmpty) {
        try {
          final response3 = await _supabaseClient
              .from('recycling_center')
              .select()
              .ilike('center_name', '%${location.toLowerCase()}%');
          
          if (response3.isNotEmpty) {
            print('Strategy 3 found ${response3.length} centers');
            results = _parseRecyclingCenters(response3);
          }
        } catch (e) {
          print('Strategy 3 failed: $e');
        }
      }
      
      // Strategy 4: If still no results, return all centers (fallback)
      if (results.isEmpty) {
        print('No specific matches found, returning all centers as fallback');
        if (allCenters.isNotEmpty) {
          results = _parseRecyclingCenters(allCenters);
        }
      }
      
      print('Final result: ${results.length} recycling centers');
      return results;
      
    } catch (e) {
      print('Error fetching recycling centers: $e');
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }
  
  List<Recycling_UserModel> _parseRecyclingCenters(dynamic response) {
    if (response is List) {
      return response.map((item) {
        try {
          return Recycling_UserModel.fromJson(item);
        } catch (e) {
          print('Error parsing recycling center: $e');
          print('Item data: $item');
          return null;
        }
      }).where((center) => center != null).cast<Recycling_UserModel>().toList();
    } else if (response is Map<String, dynamic>) {
      try {
        return [Recycling_UserModel.fromJson(response)];
      } catch (e) {
        print('Error parsing single recycling center: $e');
        print('Response data: $response');
        return [];
      }
    }
    return [];
  }
}