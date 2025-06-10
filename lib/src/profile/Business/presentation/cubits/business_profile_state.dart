import 'package:equatable/equatable.dart';
import 'package:greenloop/src/profile/Business/domain/entity/business_user.dart';

abstract class BusinessProfileState extends Equatable {
  const BusinessProfileState();

  @override
  List<Object?> get props => [];
}

class BusinessProfileInitial extends BusinessProfileState {
  const BusinessProfileInitial();
}

class BusinessProfileLoading extends BusinessProfileState {
  const BusinessProfileLoading();
}

class BusinessProfileLoaded extends BusinessProfileState {
  final Business business;
  const BusinessProfileLoaded(this.business);
}

class BusinessProfileUpdating extends BusinessProfileState {
  const BusinessProfileUpdating();
}

class BusinessProfileUploadingAvatar extends BusinessProfileState {
  const BusinessProfileUploadingAvatar();
}

class BusinessProfileError extends BusinessProfileState {
  final String message;

  const BusinessProfileError(this.message);

  @override
  List<Object> get props => [message];
}
