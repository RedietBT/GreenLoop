import 'package:greenloop/core/utils/typedefs.dart';

abstract class AuthRepo {
const AuthRepo();
  ResultFuture<AuthRepo> signInWithEmailAndPassword(String email, String password);
  ResultFuture<AuthRepo> signUpWithEmailAndPassword(String email, String password, String firstName, String lastName, String? role);
  ResultFuture<void> signOut();
  ResultFuture<String?> getCurrentUserEmail();
  ResultFuture<String?> getCurrentUserId();
  }