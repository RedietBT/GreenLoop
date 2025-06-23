import 'package:greenloop/core/usecases/usecase.dart';
import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/pickup_request/domain/entities/pickup_request.dart';
import 'package:greenloop/src/pickup_request/domain/repos/pickup_request_repo.dart';

class GetPickupRequests extends UsecaseWithParams<List<PickupRequest>, String> {
  final PickupRequestRepo _repo;

  GetPickupRequests(this._repo);

  @override
  ResultFuture<List<PickupRequest>> call(String params) {
    return _repo.getPickupRequests(params);
  }
} 