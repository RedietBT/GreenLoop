import 'package:equatable/equatable.dart';

abstract class RegisterForBusinessState extends Equatable {
  const RegisterForBusinessState();

  @override
  List<Object?> get props => [];
}

// Initial state when nothing has happened yet
class RegisterForBusinessInitial extends RegisterForBusinessState {}

// Loading state when the registration is in progress
class RegisterForBusinessLoading extends RegisterForBusinessState {}

// Success state when the registration is successful
class RegisterForBusinessSuccess extends RegisterForBusinessState {}

// Failure state when registration fails
class RegisterForBusinessFailure extends RegisterForBusinessState {
  final String error;

  const RegisterForBusinessFailure(this.error);

  @override
  List<Object?> get props => [error];

  String? get message => null;
}
