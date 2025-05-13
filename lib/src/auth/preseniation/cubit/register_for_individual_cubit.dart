import 'package:bloc/bloc.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_for_individual_state.dart';
import 'package:greenloop/src/auth/domain/repos/register_new_use_repor.dart';
import 'package:greenloop/src/auth/data/datasources/auth_remote_data_source.dart';
import 'package:greenloop/src/auth/data/datasources/role_remote_data_source.dart';
import 'package:greenloop/src/auth/data/models/role_model.dart';


class RegisterForIndividualCubit extends Cubit<RegisterForIndividualState> {
  final RegisterNewUserRepo registerRepo;
  final AuthRemoteDataSource authRemoteDataSource;
  final RoleRemoteDataSource role; 

  RegisterForIndividualCubit({
    required this.registerRepo,
    required this.authRemoteDataSource,
    required this.role,
  }) : super(RegisterForIndividualInitial());

  Future<void> registerIndividual({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String userType, // e.g., "Individual / Household"
  }) async {
    emit(RegisterForIndividualLoading());

    try {
      // 1. Load roles from Supabase
      final roles = await role.getRoles(); // Make sure this exists

  // 2. Match role by name
  final matchedRole = roles.firstWhere(
  (role) => role.name == userType,
  orElse: () => const RoleModel(id: '', name: ''),

  );

if (matchedRole.id.isEmpty) {
  emit(RegisterForIndividualFailure("Role not found for type: $userType"));
  return;
}

final roleId = matchedRole.id;


      // 3. Sign up the user in Supabase Auth
      final supabaseUser = await authRemoteDataSource.signUpWithEmailAndPassword(
        email,
        password,
        firstName,
        lastName,
        roleId,
      );

      if (supabaseUser == null) {
        emit(RegisterForIndividualFailure("Sign-up failed: User is null"));
        return;
      }

      // 4. Insert user profile
      final result = await registerRepo.insertUserProfile(
        supabaseUser.id,
        firstName,
        lastName,
        email,
        roleId,
      );

      result.fold(
        (failure) => emit(RegisterForIndividualFailure(failure.message)),
        (_) => emit(RegisterForIndividualSuccess()),
      );
    } catch (e) {
      emit(RegisterForIndividualFailure("Registration failed: ${e.toString()}"));
    }
  }
}
