import 'package:equatable/equatable.dart';
import 'package:greenloop/src/pickup_request/domain/entities/pickup_request.dart';

abstract class PickupRequestState extends Equatable {
  const PickupRequestState();
  @override
  List<Object> get props => [];
}

class PickupRequestInitial extends PickupRequestState {}

class PickupRequestLoading extends PickupRequestState {}

class PickupRequestLoaded extends PickupRequestState {
  final List<PickupRequest> requests;
  const PickupRequestLoaded(this.requests);
  @override
  List<Object> get props => [requests];
}

class PickupRequestStatusUpdated extends PickupRequestState {}

class PickupRequestError extends PickupRequestState {
  final String message;
  const PickupRequestError(this.message);
  @override
  List<Object> get props => [message];
} 