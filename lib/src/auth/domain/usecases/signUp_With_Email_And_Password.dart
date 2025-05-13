import 'package:greenloop/src/auth/domain/repos/auth_repo.dart';
import 'package:greenloop/core/utils/typedefs.dart';

class SignUpWithEmailAndPasswordUseCase {
  final AuthRepo repository;

  SignUpWithEmailAndPasswordUseCase(this.repository);

  ResultFuture<AuthRepo> call(String email, String password, String firstName, String lastName, String? role) {
    return repository.signUpWithEmailAndPassword(email, password, firstName, lastName , role);
  }
}
