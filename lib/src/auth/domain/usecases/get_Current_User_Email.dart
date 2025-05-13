import 'package:greenloop/src/auth/domain/repos/auth_repo.dart';
import 'package:greenloop/core/utils/typedefs.dart';

class GetCurrentUserEmail {
  final AuthRepo repository;

  GetCurrentUserEmail(this.repository);

  ResultFuture<String?> call() {
    return repository.getCurrentUserEmail();
  }
}