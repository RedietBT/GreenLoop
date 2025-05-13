import 'package:greenloop/src/auth/domain/repos/auth_repo.dart';
import 'package:greenloop/core/utils/typedefs.dart';


class SignInWithEmailAndPasswordUseCase {
  final AuthRepo repository;

  SignInWithEmailAndPasswordUseCase(this.repository);

  ResultFuture<AuthRepo> call(String email, String password) {
    return repository.signInWithEmailAndPassword(email, password);
  }
}
