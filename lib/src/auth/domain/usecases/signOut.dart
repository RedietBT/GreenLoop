import 'package:greenloop/src/auth/domain/repos/auth_repo.dart';
import 'package:greenloop/core/utils/typedefs.dart';

class Signout {
  final AuthRepo repository;

  Signout(this.repository);

  ResultFuture<void> call() {
    return repository.signOut();
  }
}