import 'dart:math';
import 'package:greenloop/core/errors/exceptions.dart';
import 'package:greenloop/src/profile/recycling/data/model/recycling_user_model.dart';
import 'package:greenloop/src/waste/data/model/weast_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';

abstract class WeastRemotDataSource {

  const WeastRemotDataSource();
  Future<void> insertWeastProfile(
     String weastId,
     String userId,
     String type,
     String quantity,
     LatLng? location,
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
  Future<List<Recycling_UserModel>> fetchClosestRecyclingCenters(LatLng userLocation);
  
  // New method to increment user's waste count
  Future<void> incrementUserWasteCount(String userId);
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
     LatLng? location,
  ) async {
    try {
      // Insert the waste submission
      await _supabaseClient.from('waste_submission').insert({
        'id': weastId,
        'userID': userId,
        'type': type,
        'quantity': quantity,
        'location': location != null ? WeastModel.formatLocationForDatabase(location) : null,
      });
      
      // Increment the user's waste count
      await incrementUserWasteCount(userId);
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

  @override
  Future<List<Recycling_UserModel>> fetchClosestRecyclingCenters(LatLng userLocation) async {
    try {
      print('Fetching closest recycling centers to: ${userLocation.latitude}, ${userLocation.longitude}');
      
      // Get all recycling centers
      final allCenters = await _supabaseClient
          .from('recycling_center')
          .select();
      
      if (allCenters.isEmpty) {
        print('No recycling centers found in database');
        return [];
      }
      
      // Parse centers and calculate distances
      List<Recycling_UserModel> centers = _parseRecyclingCenters(allCenters);
      List<MapEntry<Recycling_UserModel, double>> centersWithDistance = [];
      
      for (var center in centers) {
        if (center.location != null) {
          double distance = _calculateDistance(userLocation, center.location!);
          centersWithDistance.add(MapEntry(center, distance));
        }
      }
      
      // Sort by distance (closest first)
      centersWithDistance.sort((a, b) => a.value.compareTo(b.value));
      
      // Return sorted list of centers
      List<Recycling_UserModel> sortedCenters = centersWithDistance.map((entry) => entry.key).toList();
      
      print('Found ${sortedCenters.length} recycling centers, sorted by distance');
      return sortedCenters;
      
    } catch (e) {
      print('Error fetching closest recycling centers: $e');
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }
  
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    double lat1Rad = point1.latitude * (pi / 180);
    double lat2Rad = point2.latitude * (pi / 180);
    double deltaLatRad = (point2.latitude - point1.latitude) * (pi / 180);
    double deltaLonRad = (point2.longitude - point1.longitude) * (pi / 180);
    
    double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLonRad / 2) * sin(deltaLonRad / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
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

  @override
  Future<void> incrementUserWasteCount(String userId) async {
    try {
      // First, get the current waste count from the profile table
      final currentUser = await _supabaseClient
          .from('profile')
          .select('no_of_weaste')
          .eq('id', userId)
          .single();
      
      final currentCount = currentUser['no_of_weaste'] as int? ?? 0;
      final newCount = currentCount + 1;
      
      // Update the user's waste count in the profile table
      await _supabaseClient
          .from('profile')
          .update({'no_of_weaste': newCount})
          .eq('id', userId);
          
    } catch (e) {
      throw ServerException(
        message: 'Failed to increment user waste count: $e',
        statusCode: 500,
      );
    }
  }
}