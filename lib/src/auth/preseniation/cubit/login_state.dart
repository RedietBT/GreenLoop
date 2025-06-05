part of 'login_cubit.dart';
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String userId;
  final String role;
LoginSuccess({required this.userId, required this.role});
}

class LoginFailure extends LoginState {
  final String message;
  LoginFailure(this.message);
}
