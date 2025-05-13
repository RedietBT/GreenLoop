import 'package:greenloop/core/utils/typedefs.dart';

abstract class RegisterNewUserRepo {
  const RegisterNewUserRepo();
  ResultFuture<void> insertUserProfile(String id, String firstName, String lastName, String email, String? role);
  ResultFuture<void> insertIntoRecyclinTable(String id, String centerName, String contactInfo, String email, String? role);
}
