part of 'on_boarding_cubit.dart';

abstract class OnBoardingState extends Equatable {
  const OnBoardingState();
    @override
  List<Object> get props => [];
}

class OnBoardingInitial extends OnBoardingState {
  const OnBoardingInitial();
}

class CasheFirstTimer extends OnBoardingState {
  const CasheFirstTimer();
}

class CheckIfUserisFirstTimerState extends OnBoardingState {
  const CheckIfUserisFirstTimerState();
}


class UserCashed extends OnBoardingState {
  const UserCashed();
}
class OnBoardingStaus extends OnBoardingState {
  const OnBoardingStaus({required this.isFirstTimeUser});
  final bool isFirstTimeUser;
  @override
  List<Object> get props => [isFirstTimeUser];
}

class OnBoardingError extends OnBoardingState {
  const OnBoardingError({required this.message});
  final String message;
  @override
  List<String> get props => [message];
}