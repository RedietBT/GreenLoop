import 'package:dartz/dartz.dart';
import 'package:greenloop/core/errors/exceptions.dart';
import 'package:greenloop/core/errors/failure.dart';
import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/on_boarding/domain/repos/on_bording_repo.dart';
import 'package:greenloop/src/on_boarding/data/datasources/on_boarding_local_data_source.dart';
class OnBoardingRepoImpl implements OnBoardingRepo{

  const OnBoardingRepoImpl(this._localDataSource);
  final OnBoardingLocalDataSource _localDataSource;
  @override
  ResultFuture<void> casheFirstTimeUser() async {
    try {
      await _localDataSource.casheFirstTimeUser();
      return const Right(null);
      }on CacheException catch (e) {
        return Left(CacheFailure(message: e.message, statusCode: e.statusCode));
        }
  }

  @override
ResultFuture<bool> checkIfUserisFirstTimer() async {
  try {
    final result = await _localDataSource.checkIfUserisFirstTimer();
    return Right(result);
  } on CacheException catch (e) {
    return Left(CacheFailure(message: e.message, statusCode: e.statusCode));
  }
}

}