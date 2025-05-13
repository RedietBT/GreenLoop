import 'package:greenloop/src/auth/domain/repos/register_new_use_repor.dart';
import 'package:greenloop/core/utils/typedefs.dart';

class InsertIntoRecyclinTable {
  final RegisterNewUserRepo repository;

  InsertIntoRecyclinTable (this.repository);

  ResultFuture<void> call(String id, String centerName, String contactInfo, String email, String role) {
    return repository.insertIntoRecyclinTable(id, centerName, contactInfo, email, role);
  }
}