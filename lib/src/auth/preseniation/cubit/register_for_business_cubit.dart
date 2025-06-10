import 'package:bloc/bloc.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_for_business_state.dart';
import 'package:greenloop/src/auth/domain/repos/register_new_use_repor.dart';
import 'package:greenloop/src/auth/data/datasources/auth_remote_data_source.dart';
import 'package:greenloop/src/auth/data/datasources/role_remote_data_source.dart';
import 'package:greenloop/src/auth/data/models/role_model.dart';


class RegisterForBusinessCubit extends Cubit<RegisterForBusinessState> {
  final RegisterNewUserRepo registerRepo;
  final AuthRemoteDataSource authRemoteDataSource;
  final RoleRemoteDataSource role; 

  RegisterForBusinessCubit({
    required this.registerRepo,
    required this.authRemoteDataSource,
    required this.role,
  }) : super(RegisterForBusinessInitial());

  Future<void> registerBussiness({
    required String email,
    required String password,
    required String userType,
    required String businessName,
    required String contactPersonFirstName,
    required String contactPersonLastName,
    required String phoneNo,
  }) async {
    emit(RegisterForBusinessLoading());

    try {
      // 1. Load roles from Supabase
      final roles = await role.getRoles(); // Make sure this exists

  // 2. Match role by name
  final matchedRole = roles.firstWhere(
  (role) => role.name == userType,
  orElse: () => const RoleModel(id: '', name: ''),

  );

if (matchedRole.id.isEmpty) {
  emit(RegisterForBusinessFailure("Role not found for type: $userType"));
  return;
}

final roleId = matchedRole.id;


      // 3. Sign up the user in Supabase Auth
      final supabaseUser = await authRemoteDataSource.signUpWithEmailAndPassword(
        email,
        password,
        contactPersonFirstName,
        contactPersonLastName,
        roleId,
      );

      if (supabaseUser == null) {
        emit(RegisterForBusinessFailure("Sign-up failed: User is null"));
        return;
      }

      // 4. Insert user profile
      final result = await registerRepo.insertIntoBusinessTable(
        supabaseUser.id,
        businessName,
        contactPersonFirstName,
        contactPersonLastName,
        email,
        phoneNo,
        roleId,
      );

      result.fold(
        (failure) => emit(RegisterForBusinessFailure(failure.message)),
        (_) => emit(RegisterForBusinessSuccess()),
      );
    } catch (e) {
      emit(RegisterForBusinessFailure("Registration failed: ${e.toString()}"));
    }
  }
}
