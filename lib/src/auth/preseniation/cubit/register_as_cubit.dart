import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'register_as_state.dart';

class RegisterAsCubit extends Cubit<RegisterAsState> {
  RegisterAsCubit() : super(RegisterAsInitial());

  void selectRole(String role) {
    emit(RegisterAsLoading()); // Emit loading state

    Future.delayed(const Duration(seconds: 2), () {
      if (!isClosed) {
        emit(RegisterAsRoleSelected(role)); // Emit selected role if cubit is still active
      }
    });
  }
}
