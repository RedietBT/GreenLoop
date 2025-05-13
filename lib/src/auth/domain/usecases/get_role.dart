import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/auth/domain/entity/role.dart';
import 'package:greenloop/src/auth/domain/repos/role_repo.dart';
class GetRolesUseCase {
  final RoleRepository repository;

  GetRolesUseCase(this.repository);

  ResultFuture<List<Role>> execute() async {
    return await repository.getRoles();
  }
}
