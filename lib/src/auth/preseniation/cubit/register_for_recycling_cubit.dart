import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/auth/domain/repos/register_new_use_repor.dart';
import 'package:greenloop/src/auth/data/datasources/auth_remote_data_source.dart';
import 'package:greenloop/src/auth/data/datasources/role_remote_data_source.dart';
import 'package:greenloop/src/auth/data/models/role_model.dart';

part 'register_for_recycling_state.dart';

class RegisterForRecyclingCubit extends Cubit<RegisterForRecyclingState> {
  final RegisterNewUserRepo repository;
  final AuthRemoteDataSource authRemoteDataSource;
  final RoleRemoteDataSource role; 

  RegisterForRecyclingCubit({
    required this.repository,
    required this.authRemoteDataSource,
    required this.role,
 } ) : super(RegisterForRecyclingInitial());

  Future<void> registerRecycling({
    required String centerName,
    required String contactInfo,
    required String email,
    required String userType,
    required String password,
  }) async {
    emit(RegisterForRecyclingLoading());
    
    try {
      // 1. Load roles from Supabase
      final roles = await role.getRoles(); // Make sure this exists
      
      // 2. Match role by name
      final matchedRole = roles.firstWhere(
        (r) => r.name == userType,
        orElse: () => const RoleModel(id: '', name: ''),
      );
      
      if (matchedRole.id.isEmpty) {
        emit(RegisterForRecyclingError("Role not found for type: $userType"));
        return;
        }
        
        final roleId = matchedRole.id;
        
        // 3. Sign up the user in Supabase Auth
        final supabaseUser = await authRemoteDataSource.signUpWithEmailAndPassword(
          email,
          password,
          centerName,
          contactInfo,
          roleId,
        );
        
        if (supabaseUser == null) {
          emit(RegisterForRecyclingError("Sign-up failed: User is null"));
          return;
        }

        // 4. Insert Recycling profile
        final result = await repository.insertIntoRecyclinTable(
          supabaseUser.id,
          centerName,
          contactInfo,
          email,
          roleId,
          );
          
          result.fold(
            (failure) => emit(RegisterForRecyclingError(failure.message)),
            (_) => emit(RegisterForRecyclingSuccess()),
          );
        } catch (e) {
          emit(RegisterForRecyclingError("An error occurred:${e.toString()}"));
        }
      }
    }
