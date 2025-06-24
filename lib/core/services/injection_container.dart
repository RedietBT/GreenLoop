import 'package:get_it/get_it.dart';

import 'package:greenloop/src/profile/cores/data/dataSource/storage_remote_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Onboarding imports
import 'package:greenloop/src/on_boarding/data/datasources/on_boarding_local_data_source.dart';
import 'package:greenloop/src/on_boarding/data/repos/on_boarding_repo_impl.dart';
import 'package:greenloop/src/on_boarding/domain/usecases/cashe_first_timer.dart';
import 'package:greenloop/src/on_boarding/domain/usecases/check_if_user_is_first_timer.dart';
import 'package:greenloop/src/on_boarding/domain/repos/on_bording_repo.dart';
import 'package:greenloop/src/on_boarding/presentation/cubit/on_boarding_cubit.dart';

// Auth imports
import 'package:greenloop/src/auth/domain/repos/auth_repo.dart';
import 'package:greenloop/src/auth/data/repos/auth_repository_impl.dart';
import 'package:greenloop/src/auth/data/datasources/auth_remote_data_source.dart';
import 'package:greenloop/src/auth/preseniation/cubit/login_cubit.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_as_cubit.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_for_individual_cubit.dart';
import 'package:greenloop/src/auth/domain/repos/register_new_use_repor.dart';
import 'package:greenloop/src/auth/data/repos/register_new_user_repository_impl.dart';
import 'package:greenloop/src/auth/data/datasources/register_new_user_remote_data_source.dart';
import 'package:greenloop/src/auth/data/datasources/role_remote_data_source.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_for_recycling_cubit.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_for_business_cubit.dart';

// Individual Profile imports
import 'package:greenloop/src/profile/Individual/data/datasourves/individual_user_remot_data_sorce.dart';
import 'package:greenloop/src/profile/Individual/data/repos/individual_user_repo_impl.dart';
import 'package:greenloop/src/profile/Individual/domian/repos/individual_user_repo.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_cubit.dart';
import 'package:greenloop/src/profile/cores/domain/repos/storage_repo.dart';
import 'package:greenloop/src/profile/cores/data/repos/storage_repo_impl.dart';


// Recycling Profile imports
import 'package:greenloop/src/profile/recycling/data/datasource/recycling_remote_data_source.dart';
import 'package:greenloop/src/profile/recycling/presentation/cubits/recycling_profile_cubit.dart';
import 'package:greenloop/src/profile/recycling/data/repos/recycling_repo_impl.dart';
import 'package:greenloop/src/profile/recycling/domain/repos/recycling_user_repo.dart';

//Business Profile imports
import 'package:greenloop/src/profile/Business/data/datasource/business_remote_data_source.dart';
import 'package:greenloop/src/profile/Business/data/repos/business_repo_impl.dart';
import 'package:greenloop/src/profile/Business/domain/repo/business_repo.dart';
import 'package:greenloop/src/profile/Business/presentation/cubits/business_profile_cubit.dart';

// Waste imports
import 'package:greenloop/src/waste/data/dataSource/weast_remot_data_source.dart';
import 'package:greenloop/src/waste/data/repos/weast_repo_impl.dart';
import 'package:greenloop/src/waste/domain/repos/weast_repo.dart';
import 'package:greenloop/src/waste/domain/usecase/insert_weast_profile.dart';
import 'package:greenloop/src/waste/domain/usecase/update_weast_profile.dart';
import 'package:greenloop/src/waste/domain/usecase/fetch_recyling_profile.dart';
import 'package:greenloop/src/waste/domain/usecase/fetch_closest_recycling_centers.dart';
import 'package:greenloop/src/waste/domain/usecase/request_for_pickup.dart';
import 'package:greenloop/src/waste/presentation/cubits/weast_cubit.dart';
import 'package:greenloop/src/waste/domain/usecase/increment_user_waste_count.dart';

// Pickup Request imports
import 'package:greenloop/src/pickup_request/data/datasources/pickup_request_remote_data_source.dart';
import 'package:greenloop/src/pickup_request/data/repos/pickup_request_repo_impl.dart';
import 'package:greenloop/src/pickup_request/domain/repos/pickup_request_repo.dart';
import 'package:greenloop/src/pickup_request/domain/usecases/get_pickup_requests.dart';
import 'package:greenloop/src/pickup_request/domain/usecases/update_pickup_request_status.dart';
import 'package:greenloop/src/pickup_request/presentation/cubit/pickup_request_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  /// Core
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Supabase client
  sl.registerLazySingleton(() => Supabase.instance.client);

  // ============================
  // OnBoarding Feature
  // ============================

  // Cubit
  sl.registerFactory(() => OnBoardingCubit(
        casheFirstTimeUser: sl(),
        checkIfUserisFirstTimer: sl(),
      ));

  // Usecases
  sl.registerLazySingleton(() => CasheFirstTimeUser(sl()));
  sl.registerLazySingleton(() => CheckIfUserisFirstTimer(sl()));

  // Repository & Data Source
  sl.registerLazySingleton<OnBoardingRepo>(() => OnBoardingRepoImpl(sl()));
  sl.registerLazySingleton<OnBoardingLocalDataSource>(
    () => OnBoardingLocalDataSourceImpl(sl()),
  );

  // ============================
  // Auth Feature (Login & Register)
  // ============================

  // Remote Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<RegisterNewUserRemoteDataSource>(
    () => RegisterNewUserRemoteDataSourceImpl(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<RoleRemoteDataSource>(
    () => RoleRemoteDataSourceImpl(sl<SupabaseClient>()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepo>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  sl.registerLazySingleton<RegisterNewUserRepo>(
    () => RegisterNewUserRepositoryImpl(sl<RegisterNewUserRemoteDataSource>()),
  );

  // Cubits
  sl.registerFactory(() => LoginCubit(
    sl<AuthRepo>(),
    sl<IndividualUserRepo>(),
    sl<BusinessRepo>(),
    sl<RecyclingUserRepo>(),
  ));
  sl.registerFactory(() => RegisterAsCubit());

  sl.registerFactory(() => RegisterForIndividualCubit(
        registerRepo: sl<RegisterNewUserRepo>(),
        authRemoteDataSource: sl<AuthRemoteDataSource>(),
        role: sl<RoleRemoteDataSource>(),
      ));

     sl.registerFactory(() => RegisterForBusinessCubit(
        registerRepo: sl<RegisterNewUserRepo>(),
        authRemoteDataSource: sl<AuthRemoteDataSource>(),
        role: sl<RoleRemoteDataSource>(),
      ));

  sl.registerFactory(() => RegisterForRecyclingCubit(
    repository: sl<RegisterNewUserRepo>(),
    authRemoteDataSource: sl<AuthRemoteDataSource>(),
    role: sl<RoleRemoteDataSource>(),
    ));

// ============================
  // NEW: Individual Profile Feature
  // ============================

  // Data Sources
  sl.registerLazySingleton<IndividualUserRemoteDataSource>(
    () => IndividualUserRemoteDataSourceImpl(sl<SupabaseClient>()),
  );

 sl.registerLazySingleton<StorageRemoteDataSource>(
  () => StorageRemoteDataSourceImpl(sl<SupabaseClient>()),
);
  
  // Repositories
  // Assuming IndividualUserRepo is your abstract interface for the repository
  sl.registerLazySingleton<IndividualUserRepo>(
    () => IndividualUserRepoImpl(sl<IndividualUserRemoteDataSource>()),
  );

  sl.registerLazySingleton<StorageRepo>(
  () => StorageRepoImpl(sl<StorageRemoteDataSource>()),
);

  // Cubit
  // Assuming IndividualProfileCubit depends on IndividualUserRepo
  sl.registerFactory(() => IndividualProfileCubit(
    sl<IndividualUserRepo>(), 
    sl<StorageRepo>()
    )
    );

    // ============================
  // NEW:Business Profile Feature
  // ============================
  // Data Sources
  sl.registerLazySingleton<BusinessRemoteDataSource>(
    () => BusinessRemoteDataSourceImpl(sl<SupabaseClient>()),
  );
  // Repositories
  sl.registerLazySingleton<BusinessRepo>(
    () => BusinessRepoImpl(sl<BusinessRemoteDataSource>()),
  );

  // Cubit
  sl.registerFactory(() => BusinessProfileCubit(
    businessRepo: sl<BusinessRepo>(),
    storageRepo: sl<StorageRepo>()
  ));

  // ============================
  // NEW:Recycling Profile Feature
  // ============================
  // Data Sources
  sl.registerLazySingleton<RecyclingRemoteDataSource>(
    () => RecyclingRemoteDataSourceImpl(sl<SupabaseClient>()),
  );
  // Repositories
  sl.registerLazySingleton<RecyclingUserRepo>(
    () => RecyclingUserRepoImpl(sl<RecyclingRemoteDataSource>()),
  );
  // Cubit
  sl.registerFactory(() => RecyclingProfileCubit(
    sl<RecyclingUserRepo>(),
    sl<StorageRepo>(),
  ));

  // ============================
  // NEW: Waste Feature
  // ============================
  // Data Sources
  sl.registerLazySingleton<WeastRemotDataSource>(
    () => WeastRemotDataSourceImpl(sl<SupabaseClient>()),
  );
  
  // Repositories
  sl.registerLazySingleton<WeastRepo>(
    () => WeastRepoImpl(sl<WeastRemotDataSource>()),
  );
  
  // Use Cases
  sl.registerLazySingleton(() => InsertWeastProfile(sl<WeastRepo>()));
  sl.registerLazySingleton(() => UpdateWeastProfile(sl<WeastRepo>()));
  sl.registerLazySingleton(() => FetchRecylingCenters(sl<WeastRepo>()));
  sl.registerLazySingleton(() => FetchClosestRecyclingCenters(sl<WeastRepo>()));
  sl.registerLazySingleton(() => RequestForPickup(sl<WeastRepo>()));
  sl.registerLazySingleton(() => IncrementUserWasteCount(sl<WeastRepo>()));
  
  // Cubit
  sl.registerFactory(() => WeastCubit(
    insertWeastProfile: sl<InsertWeastProfile>(),
    updateWeastProfile: sl<UpdateWeastProfile>(),
    fetchRecylingCenters: sl<FetchRecylingCenters>(),
    fetchClosestRecyclingCenters: sl<FetchClosestRecyclingCenters>(),
    requestForPickup: sl<RequestForPickup>(),
  ));

  // ============================
  // Pickup Request Feature
  // ============================

  // Remote Data Source
  sl.registerLazySingleton<PickupRequestRemoteDataSource>(
    () => PickupRequestRemoteDataSourceImpl(sl<SupabaseClient>()),
  );

  // Repository
  sl.registerLazySingleton<PickupRequestRepo>(
    () => PickupRequestRepoImpl(sl<PickupRequestRemoteDataSource>()),
  );

  // Usecases
  sl.registerLazySingleton(() => GetPickupRequests(sl<PickupRequestRepo>()));
  sl.registerLazySingleton(
      () => UpdatePickupRequestStatus(sl<PickupRequestRepo>()));

  // Cubit
  sl.registerFactory(() => PickupRequestCubit(
        getPickupRequests: sl<GetPickupRequests>(),
        updatePickupRequestStatus: sl<UpdatePickupRequestStatus>(),
      ));
}
