import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/auth/domain/repos/auth_repo.dart';


class GetCurrentUserid {
  final AuthRepo repository;


  GetCurrentUserid(this.repository);

  ResultFuture<String?> call() {
    return repository.getCurrentUserId();
  }
}