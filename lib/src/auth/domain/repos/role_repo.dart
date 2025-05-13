import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/auth/domain/entity/role.dart';

abstract class RoleRepository {
  const RoleRepository();
 ResultFuture<List<Role>> getRoles();
}
