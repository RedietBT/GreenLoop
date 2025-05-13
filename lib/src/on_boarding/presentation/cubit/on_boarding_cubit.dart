import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:greenloop/src/on_boarding/domain/usecases/cashe_first_timer.dart';
import 'package:greenloop/src/on_boarding/domain/usecases/check_if_user_is_first_timer.dart';


part 'on_boarding_state.dart';

class OnBoardingCubit extends Cubit<OnBoardingState> {
  OnBoardingCubit({
 required CasheFirstTimeUser casheFirstTimeUser,
 required CheckIfUserisFirstTimer checkIfUserisFirstTimer,
}) :  _casheFirstTimeUser = casheFirstTimeUser,
       _checkIfUserisFirstTimer = checkIfUserisFirstTimer,
       super(const OnBoardingInitial());

  final CasheFirstTimeUser _casheFirstTimeUser;
  final CheckIfUserisFirstTimer _checkIfUserisFirstTimer;
  

  Future<void> casheFirstTimeUser() async {
   
    final result = await _casheFirstTimeUser();
    result.fold(
      (failure) => emit(OnBoardingError(message: failure.errorMassage)),
      (_) => emit(const UserCashed()),
      );
  }

  Future<void> checkIfUserisFirstTimer() async {
    
    final result = await _checkIfUserisFirstTimer();
    result.fold(
      (failure) => emit(OnBoardingStaus(isFirstTimeUser: false)),
      (status) => emit(OnBoardingStaus(isFirstTimeUser: status)),
    );
  }
}
