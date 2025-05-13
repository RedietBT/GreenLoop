import 'package:greenloop/src/auth/data/models/role_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class RoleRemoteDataSource {
  const RoleRemoteDataSource();
  Future<List<RoleModel>> getRoles();
}
class RoleRemoteDataSourceImpl implements RoleRemoteDataSource {
  const RoleRemoteDataSourceImpl(this._client);
  final SupabaseClient _client;

  @override
  Future<List<RoleModel>> getRoles() async {
 final response = await _client.rpc('get_roles');
 final data = response as List<dynamic>;
     return data.map((json) => RoleModel.fromJson(json as Map<String, dynamic>)).toList();
}
}