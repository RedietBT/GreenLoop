part of 'register_for_recycling_cubit.dart';

abstract class RegisterForRecyclingState {
  const RegisterForRecyclingState();
}

class RegisterForRecyclingInitial extends RegisterForRecyclingState {}

class RegisterForRecyclingLoading extends RegisterForRecyclingState {}

class RegisterForRecyclingSuccess extends RegisterForRecyclingState {}

class RegisterForRecyclingError extends RegisterForRecyclingState {
  final String message;
  const RegisterForRecyclingError(this.message);
}
