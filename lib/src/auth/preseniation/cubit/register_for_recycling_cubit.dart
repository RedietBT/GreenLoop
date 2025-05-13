import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/auth/domain/repos/register_new_use_repor.dart';

part 'register_for_recycling_state.dart';

class RegisterForRecyclingCubit extends Cubit<RegisterForRecyclingState> {
  final RegisterNewUserRepo repository;

  RegisterForRecyclingCubit(this.repository) : super(RegisterForRecyclingInitial());

  Future<void> register({
    required String id,
    required String centerName,
    required String contactInfo,
    required String email,
    required String role,
    required String password,
  }) async {
    emit(RegisterForRecyclingLoading());
    final result = await repository.insertIntoRecyclinTable(
      id,
      centerName,
      contactInfo,
      email,
      role,
    );

    result.fold(
      (failure) => emit(RegisterForRecyclingError(failure.message)),
      (_) => emit(RegisterForRecyclingSuccess()),
    );
  }
}
