import 'package:greenloop/src/on_boarding/domain/repos/on_bording_repo.dart';
import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/core/usecases/usecase.dart';

class CasheFirstTimeUser extends UsecaseWithoutParams<void> {
  const CasheFirstTimeUser(this._repo);

  final OnBoardingRepo _repo;

  @override
  ResultFuture<void> call() async {
    return await _repo.casheFirstTimeUser();
  }
}