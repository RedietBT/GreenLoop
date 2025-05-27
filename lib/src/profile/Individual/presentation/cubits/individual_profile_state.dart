import 'package:greenloop/src/profile/Individual/domian/entity/individual_user.dart';

abstract class IndividualProfileState {}

class IndividualProfileInitial extends IndividualProfileState {}

class IndividualProfileLoading extends IndividualProfileState {}

class IndividualProfileLoaded extends IndividualProfileState {
  final Individual_User user;
  IndividualProfileLoaded(this.user);
}
class IndividualProfileUploadingAvatar extends IndividualProfileState {}

class IndividualProfileUpdating extends IndividualProfileState {}

class IndividualProfileError extends IndividualProfileState {
  final String message;
  IndividualProfileError(this.message);
}
