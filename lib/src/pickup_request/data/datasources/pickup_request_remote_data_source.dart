import 'package:greenloop/core/errors/exceptions.dart';
import 'package:greenloop/src/pickup_request/data/models/pickup_request_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class PickupRequestRemoteDataSource {
  Future<List<PickupRequestModel>> getPickupRequests(String recyclingCenterId);
  Future<void> updatePickupRequestStatus(
      {required String requestId, required String status});
}

class PickupRequestRemoteDataSourceImpl
    implements PickupRequestRemoteDataSource {
  final SupabaseClient _client;

  PickupRequestRemoteDataSourceImpl(this._client);

  @override
  Future<List<PickupRequestModel>> getPickupRequests(
      String recyclingCenterId) async {
    try {
      print(
          'Fetching pickup requests for center ID: $recyclingCenterId using client-side joins.');

      // 1. Fetch all pickup_requests for the center
      final requestsResponse = await _client
          .from('pickup_requests')
          .select()
          .eq('recycling-centerID', recyclingCenterId);

      if (requestsResponse.isEmpty) {
        print('No pickup requests found for this center.');
        return [];
      }

      // 2. Extract IDs for further queries
      final wasteSubmissionIds = requestsResponse
          .map((req) => req['waste-submissionID'] as String)
          .toSet()
          .toList();
      final userIds = requestsResponse
          .map((req) => req['userID'] as String)
          .toSet()
          .toList();

      if (wasteSubmissionIds.isEmpty || userIds.isEmpty) {
        return [];
      }

      // 3. Fetch corresponding waste_submission, profile, and business records
      final wasteSubmissionsResponse = await _client
          .from('waste_submission')
          .select()
          .filter('id', 'in', '(${wasteSubmissionIds.join(',')})');

      final profilesResponse = await _client
          .from('profile')
          .select()
          .filter('id', 'in', '(${userIds.join(',')})');

      final businessesResponse = await _client
          .from('business')
          .select()
          .filter('id', 'in', '(${userIds.join(',')})');

      // 4. Create maps for easy lookup
      final wasteSubmissionsMap = {
        for (var ws in wasteSubmissionsResponse) ws['id']: ws
      };
      final profilesMap = {for (var p in profilesResponse) p['id']: p};
      final businessesMap = {for (var b in businessesResponse) b['id']: b};

      // 5. Combine the data
      final List<PickupRequestModel> combinedRequests = [];
      for (final requestData in requestsResponse) {
        final wasteData =
            wasteSubmissionsMap[requestData['waste-submissionID']];
        final profileData = profilesMap[requestData['userID']];
        final businessData = businessesMap[requestData['userID']];

        final combinedMap = {
          ...requestData,
          'waste_type': wasteData?['type'],
          'waste_quantity': wasteData?['quantity'],
          'waste_location': wasteData?['location'],
          'user_name': profileData?['first_name'] != null
              ? '${profileData!['first_name']} ${profileData['last_name']}'
              : businessData?['business_name'],
          'user_avatar':
              profileData?['avatar_url'] ?? businessData?['avatar_url'],
        };

        combinedRequests.add(PickupRequestModel.fromMap(combinedMap));
      }

      print(
          'Successfully combined ${combinedRequests.length} requests on the client-side.');
      return combinedRequests;
    } on PostgrestException catch (e) {
      print('Supabase Postgrest error: ${e.message}');
      throw ServerException(
          message: e.message, statusCode: int.tryParse(e.code ?? '500')!);
    } catch (e) {
      print('Generic error in getPickupRequests: $e');
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<void> updatePickupRequestStatus(
      {required String requestId, required String status}) async {
    try {
      await _client
          .from('pickup_requests')
          .update({'request-status': status}).eq('id', requestId);
    } on PostgrestException catch (e) {
      throw ServerException(
          message: e.message, statusCode: int.tryParse(e.code ?? '500')!);
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }
} 