import 'package:greenloop/core/usecases/usecase.dart';
import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/on_boarding/domain/repos/on_bording_repo.dart';

class CheckIfUserIsFirsttimer extends UsecaseWithoutParams<bool> {
  const CheckIfUserIsFirsttimer(this._repo);
  
  final OnBoardingRepo _repo;

  @override
  ResultFuture<bool> call() => _repo.checkIfUserisFirstTimer();
}