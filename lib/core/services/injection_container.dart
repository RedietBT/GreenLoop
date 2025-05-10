import 'package:get_it/get_it.dart';
import 'package:greenloop/src/on_boarding/data/datasources/on_boarding_local_data_source.dart';
import 'package:greenloop/src/on_boarding/data/repos/on_boarding_repo_impl.dart';
import 'package:greenloop/src/on_boarding/presentation/cubit/on_boarding_cubit.dart';
import 'package:greenloop/src/on_boarding/domain/usecases/cashe_first_timer.dart';
import 'package:greenloop/src/on_boarding/domain/usecases/check_if_user_is_first_timer.dart';
import 'package:greenloop/src/on_boarding/domain/repos/on_bording_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async{
  final sharedPreferences = await SharedPreferences.getInstance();
  //Feature --> OnBoarding
  // Busuness Logic
  sl.registerFactory(
    () => OnBoardingCubit(
     casheFirstTimeUser:  sl(),
     checkIfUserisFirstTimer: sl(),
    ),
  );
  sl.registerLazySingleton(() => CasheFirstTimeUser(sl()));
  sl.registerLazySingleton(() => CheckIfUserisFirstTimer(sl()));
  // Repository
  sl.registerLazySingleton<OnBoardingRepo>(() => OnBoardingRepoImpl(sl()));
  sl.registerLazySingleton<OnBoardingLocalDataSource>(() => OnBoardingLocalDataSourceImpl(sl()));
  sl.registerLazySingleton(() => sharedPreferences);
}