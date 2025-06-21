import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/waste/domain/repos/weast_repo.dart';

class RequestForPickup {

  final WeastRepo repository;
  const RequestForPickup(this.repository);

  ResultFuture<void> call(String id, {
    required String userId,
    required String weastId,
    required String recyclingCenterId,
    required String location,
    required String requestStatus,
  }) {
    return repository.requestForPickup(id, 
      userId: userId, 
      weastId: weastId, 
      recyclingCenterId: recyclingCenterId, 
      location: location, 
      requestStatus: requestStatus);
  }
}