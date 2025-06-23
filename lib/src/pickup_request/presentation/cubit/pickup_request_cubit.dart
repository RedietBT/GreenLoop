import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/pickup_request/domain/usecases/get_pickup_requests.dart';
import 'package:greenloop/src/pickup_request/domain/usecases/update_pickup_request_status.dart';
import 'package:greenloop/src/pickup_request/presentation/cubit/pickup_request_state.dart';

class PickupRequestCubit extends Cubit<PickupRequestState> {
  final GetPickupRequests _getPickupRequests;
  final UpdatePickupRequestStatus _updatePickupRequestStatus;

  PickupRequestCubit({
    required GetPickupRequests getPickupRequests,
    required UpdatePickupRequestStatus updatePickupRequestStatus,
  })  : _getPickupRequests = getPickupRequests,
        _updatePickupRequestStatus = updatePickupRequestStatus,
        super(PickupRequestInitial());

  Future<void> getPickupRequests(String recyclingCenterId) async {
    emit(PickupRequestLoading());
    final result = await _getPickupRequests(recyclingCenterId);
    result.fold(
      (failure) => emit(PickupRequestError(failure.errorMassage)),
      (requests) => emit(PickupRequestLoaded(requests)),
    );
  }

  Future<void> updateStatus(
      String requestId, String status, String recyclingCenterId) async {
    final result = await _updatePickupRequestStatus(
      UpdatePickupRequestStatusParams(requestId: requestId, status: status),
    );
    result.fold(
      (failure) => emit(PickupRequestError(failure.errorMassage)),
      (_) {
        getPickupRequests(recyclingCenterId);
      },
    );
  }
} 