import 'package:bloc/bloc.dart';
import 'package:greenloop/src/auth/domain/entity/individual_user.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_for_individual_state.dart';
import 'package:greenloop/src/auth/domain/repos/register_new_use_repor.dart';
import 'package:greenloop/src/auth/data/datasources/auth_remote_data_source.dart';


class RegisterForIndividualCubit extends Cubit<RegisterForIndividualState> {
  final RegisterNewUserRepo registerRepo;
  final AuthRemoteDataSource authRemoteDataSource;

  RegisterForIndividualCubit({
    required this.registerRepo,
    required this.authRemoteDataSource,
  }) : super(RegisterForIndividualInitial());

  Future<void> registerIndividual(IndividualUser user, String password) async {
    emit(RegisterForIndividualLoading());

    try {
      // 1. Sign up in Supabase Auth
      final supabaseUser = await authRemoteDataSource.signUpWithEmailAndPassword(
        user.email,
        password,
        user.first_name,
        user.last_name,
        user.role,
      );

      if (supabaseUser == null) {
        emit(RegisterForIndividualFailure("Sign-up failed: User is null"));
        return;
      }

      // 2. Insert into profile table using ID from Supabase Auth
      final result = await registerRepo.insertUserProfile(
        supabaseUser.id,
        user.first_name,
        user.last_name,
        user.email,
        user.role,
      );

      result.fold(
        (failure) => emit(RegisterForIndividualFailure(failure.message)),
        (_) => emit(RegisterForIndividualSuccess()),
      );
    } catch (e) {
      emit(RegisterForIndividualFailure(e.toString()));
    }
  }
}
