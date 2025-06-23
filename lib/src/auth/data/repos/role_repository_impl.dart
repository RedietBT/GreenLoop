import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/auth/data/datasources/role_remote_data_source.dart';
import 'package:greenloop/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:greenloop/src/auth/domain/repos/role_repo.dart';
import 'package:greenloop/src/auth/domain/entity/role.dart';
import 'package:greenloop/core/errors/exceptions.dart';

class RoleRepositoryImpl implements RoleRepository {

  final RoleRemoteDataSource remoteDataSource;
  const RoleRepositoryImpl(this.remoteDataSource);
  

  @override
  ResultFuture<List<Role>> getRoles() async {
    try {
      final roles = await remoteDataSource.getRoles();
      return Right(roles);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode.toString()));
    }
  }
}