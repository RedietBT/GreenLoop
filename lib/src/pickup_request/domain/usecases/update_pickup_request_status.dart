import 'package:equatable/equatable.dart';
import 'package:greenloop/core/usecases/usecase.dart';
import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/pickup_request/domain/repos/pickup_request_repo.dart';

class UpdatePickupRequestStatus
    extends UsecaseWithParams<void, UpdatePickupRequestStatusParams> {
  final PickupRequestRepo _repo;

  UpdatePickupRequestStatus(this._repo);

  @override
  ResultFuture<void> call(UpdatePickupRequestStatusParams params) {
    return _repo.updatePickupRequestStatus(
      requestId: params.requestId,
      status: params.status,
    );
  }
}

class UpdatePickupRequestStatusParams extends Equatable {
  final String requestId;
  final String status;

  const UpdatePickupRequestStatusParams(
      {required this.requestId, required this.status});

  @override
  List<Object?> get props => [requestId, status];
} 