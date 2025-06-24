import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/auth/domain/repos/auth_repo.dart';
import 'package:greenloop/src/profile/Business/domain/repo/business_repo.dart';
import 'package:greenloop/src/profile/Individual/domian/repos/individual_user_repo.dart';
import 'package:greenloop/src/profile/recycling/domain/repos/recycling_user_repo.dart';

part 'login_state.dart';
class LoginCubit extends Cubit<LoginState> {

  final AuthRepo _authRepo;
  final IndividualUserRepo _individualUserRepo;
  final BusinessRepo _businessRepo;
  final RecyclingUserRepo _recyclingUserRepo; // Assuming you have a BusinessRepo for business profiles

  LoginCubit(this._authRepo, this._individualUserRepo, this._businessRepo, this._recyclingUserRepo) : super(LoginInitial());

 Future<void> login(String email, String password) async {
    emit(LoginLoading());

    try {
      // Add a timeout to the login process
      final loginResult = await _authRepo
          .signInWithEmailAndPassword(email, password)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Login timed out. Please check your internet connection and try again.');
      });

      await loginResult.fold(
        (failure) {
          // Check for incorrect email or password (Supabase returns status 400 or message contains 'invalid')
          final msg = failure.message.toLowerCase();
          if (msg.contains('invalid') || msg.contains('incorrect') || failure.statusCode == '400') {
            emit(LoginFailure('Incorrect email or password. Please try again.'));
          } else if (msg.contains('timeout')) {
            emit(LoginFailure('Login timed out. Please check your internet connection and try again.'));
          } else {
            emit(LoginFailure(failure.message));
          }
        },
        (_) async {
          // Login itself was successful. Now, get the current user's ID string.
          final userIdResult = await _authRepo.getCurrentUserId(); // Call the method that returns String?

         await userIdResult.fold(
            (userFailure) {
              emit(LoginFailure(
                   "Login successful but failed to retrieve user ID: ${userFailure.message}"));
            },
            (userId) async {
              // userId is now already a String?
              if (userId != null && userId.isNotEmpty) {
                final role = await _determineUserRole(userId);
                emit(LoginSuccess(userId: userId, role: role ?? "")); // Pass the retrieved userId (String)
              } else {
                // Handle case where ID is null or empty after successful login
                emit(LoginFailure("Logged in, but user ID is not available."));
              }
            },
          );
        },
      );
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  Future<String?> _determineUserRole(String userId) async {
    // Try fetching Individual profile
    final individualResult = await _individualUserRepo.fetchUserProfile(userId);
    String? role;
    individualResult.fold(
      (failure) {
        print('Failed to fetch individual profile: ${failure.message}');
      },
      (user) {
        print('Found individual profile with role: ${user.role}');
        role = user.role;
      },
    );
    if (role != null) return role;

    // If not individual, try Business profile
    final businessResult = await _businessRepo.fetchUserProfile(userId);
    businessResult.fold(
      (failure) {
        print('Failed to fetch business profile: ${failure.message}');
      },
      (business) {
        print('Found business profile with role: ${business.role}');
        role = business.role;
      },
    );
    if (role != null) return role;
    final recyclingResult = await _recyclingUserRepo.fetchUserProfile(userId);
    recyclingResult.fold(
      (failure) {
        print('Failed to fetch recycling profile: ${failure.message}');
      },
      (recycling) {
        print('Found recycling profile with role: ${recycling.role}');
        role = recycling.role;
      },
    );
    if (role != null) return role;
    print('No role found for user ID: $userId');
    return null; // Role not found in any profile
  }
}
