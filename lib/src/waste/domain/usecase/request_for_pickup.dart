import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/waste/domain/repos/weast_repo.dart';

class RequestForPickup {

  final WeastRepo repository;
  const RequestForPickup(this.repository);

  ResultFuture<void> call(
    String id, 
     String userId,
     String weastId,
     String recyclingCenterId,
     String requestStatus,
  ) {
    return repository.requestForPickup(
      id, 
      userId, 
      weastId, 
      recyclingCenterId, 
      requestStatus
      );
  }
}