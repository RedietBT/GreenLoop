import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/pickup_request/domain/entities/pickup_request.dart';

abstract class PickupRequestRepo {
  ResultFuture<List<PickupRequest>> getPickupRequests(String recyclingCenterId);
  ResultFuture<void> updatePickupRequestStatus({
    required String requestId,
    required String status,
  });
} 