import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/auth/domain/repos/auth_repo.dart';

part 'login_state.dart';
class LoginCubit extends Cubit<LoginState> {

  final AuthRepo _authRepo;

  LoginCubit(this._authRepo) : super(LoginInitial());

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    final result = await _authRepo.signInWithEmailAndPassword(email, password);
    result.fold(
      (failure) => emit(LoginFailure(failure.message)),
      (_) => emit(LoginSuccess()),
    );
  }
}
