import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/auth/domain/repos/auth_repo.dart';

part 'login_state.dart';
class LoginCubit extends Cubit<LoginState> {

  final AuthRepo _authRepo;

  LoginCubit(this._authRepo) : super(LoginInitial());

 Future<void> login(String email, String password) async {
    emit(LoginLoading());

    final loginResult = await _authRepo.signInWithEmailAndPassword(email, password);

    await loginResult.fold(
      (failure) {
        emit(LoginFailure(failure.message));
      },
      (_) async {
        // Login itself was successful. Now, get the current user's ID string.
        final userIdResult = await _authRepo.getCurrentUserId(); // Call the method that returns String?

        userIdResult.fold(
          (userFailure) {
            emit(LoginFailure(
                 "Login successful but failed to retrieve user ID: ${userFailure.message}"));
          },
          (userId) {
            // userId is now already a String?
            if (userId != null && userId.isNotEmpty) {
              emit(LoginSuccess(userId: userId)); // Pass the retrieved userId (String)
            } else {
              // Handle case where ID is null or empty after successful login
              emit(LoginFailure("Logged in, but user ID is not available."));
            }
          },
        );
      },
    );
  }
}
