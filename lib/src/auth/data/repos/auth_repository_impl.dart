// data/repositories/auth_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/auth/data/datasources/auth_remote_data_source.dart';
import 'package:greenloop/src/auth/domain/repos/auth_repo.dart';
import 'package:greenloop/core/errors/exceptions.dart';
import 'package:greenloop/core/errors/failure.dart';

class AuthRepositoryImpl extends AuthRepo {
  final AuthRemoteDataSource remote;
  

  AuthRepositoryImpl(this.remote);

  @override
  ResultFuture<AuthRepo> signInWithEmailAndPassword(String email, String password) async {
    try {
      await remote.signInWithEmailAndPassword(email, password);
      return Right(this); // AuthRepo returned
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<AuthRepo> signUpWithEmailAndPassword(
    String email,
    String password,
    String firstName,
    String lastName,
    String? role,
  ) async {
    try {
      await remote.signUpWithEmailAndPassword(email, password, firstName, lastName, role);
      return Right(this);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> signOut() async {
    try {
      await remote.signOut();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<String?> getCurrentUserEmail() async {
    try {
      final email = await remote.getCurrentUserEmail();
      return Right(email);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
