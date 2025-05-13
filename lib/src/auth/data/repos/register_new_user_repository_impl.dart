// data/repositories/register_new_user_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/auth/data/datasources/register_new_user_remote_data_source.dart';
import 'package:greenloop/src/auth/domain/repos/register_new_use_repor.dart';
import 'package:greenloop/core/errors/exceptions.dart';
import 'package:greenloop/core/errors/failure.dart';

class RegisterNewUserRepositoryImpl implements RegisterNewUserRepo {
  final RegisterNewUserRemoteDataSource remoteDataSource;

 const RegisterNewUserRepositoryImpl(this.remoteDataSource);

  @override
  ResultFuture<void> insertUserProfile(
      String id, String firstName, String lastName, String email, String? role) async {
    try {
      await remoteDataSource.insertUserProfile(id, firstName, lastName, email, role);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> insertIntoRecyclinTable(
      String id, String centerName, String contactInfo, String email, String? role) async {
    try {
      await remoteDataSource.insertIntoRecyclingTable(id, centerName, contactInfo, email, role);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
