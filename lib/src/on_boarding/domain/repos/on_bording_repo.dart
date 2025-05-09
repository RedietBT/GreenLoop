import 'package:greenloop/core/utils/typedefs.dart';

abstract class OnBoardingRepo {
  const OnBoardingRepo();
  ResultFuture <void> casheFirstTimeUser();ResultFuture <bool> checkIfUserisFirstTimer();
}