import 'package:greenloop/src/auth/domain/repos/register_new_use_repor.dart';

class InsertIntoBusinessTable {

  final RegisterNewUserRepo repository;

  InsertIntoBusinessTable(this.repository);

  Future<void> call(String id, String businessName, String contactPersonFirstName, String contactPersonLastName, String email, String phoneNo, String? role) async {
    await repository.insertIntoBusinessTable(id, businessName, contactPersonFirstName, contactPersonLastName, email, phoneNo, role,);
  }
}