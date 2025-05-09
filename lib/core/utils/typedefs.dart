import 'package:dartz/dartz.dart';
import 'package:greenloop/core/errors/failure.dart';

typedef ResultFuture<T> = Future<Either<Failure, T>>;

typedef DataMap = Map<String, dynamic>;