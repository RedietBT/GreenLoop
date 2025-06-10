import 'package:greenloop/src/profile/recycling/domain/entity/recycling_user.dart';

abstract class RecyclingProfileState {}

class RecyclingProfileInitial extends RecyclingProfileState {}

class RecyclingProfileLoading extends RecyclingProfileState {}

class RecyclingProfileLoaded extends RecyclingProfileState {
  final Recycling_User user;
  RecyclingProfileLoaded(this.user);
}

class RecyclingProfileUpdating extends RecyclingProfileState {}

class RecyclingProfileError extends RecyclingProfileState {
  final String message;
  RecyclingProfileError(this.message);
} 