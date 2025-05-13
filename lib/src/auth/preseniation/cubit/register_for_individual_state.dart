// register_for_individual_state.dart

import 'package:equatable/equatable.dart';

abstract class RegisterForIndividualState extends Equatable {
  const RegisterForIndividualState();

  @override
  List<Object?> get props => [];
}

// Initial state when nothing has happened yet
class RegisterForIndividualInitial extends RegisterForIndividualState {}

// Loading state when the registration is in progress
class RegisterForIndividualLoading extends RegisterForIndividualState {}

// Success state when the registration is successful
class RegisterForIndividualSuccess extends RegisterForIndividualState {}

// Failure state when registration fails
class RegisterForIndividualFailure extends RegisterForIndividualState {
  final String error;

  const RegisterForIndividualFailure(this.error);

  @override
  List<Object?> get props => [error];

  String? get message => null;
}
