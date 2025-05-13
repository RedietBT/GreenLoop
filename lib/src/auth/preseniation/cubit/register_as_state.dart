part of 'register_as_cubit.dart';

abstract class RegisterAsState extends Equatable {
  const RegisterAsState();

  @override
  List<Object> get props => [];
}

class RegisterAsInitial extends RegisterAsState {}

class RegisterAsRoleSelected extends RegisterAsState {
  final String role;

  const RegisterAsRoleSelected(this.role);

  @override
  List<Object> get props => [role];
}

class RegisterAsLoading extends RegisterAsState {}
