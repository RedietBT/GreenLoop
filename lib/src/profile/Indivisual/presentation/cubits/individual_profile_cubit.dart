import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/profile/Indivisual/domian/repos/individual_user_repo.dart';
import 'package:greenloop/src/profile/Indivisual/presentation/cubits/individual_profile_state.dart';

class IndividualProfileCubit extends Cubit<IndividualProfileState> {
  final IndividualUserRepo individualUserRepo;

  IndividualProfileCubit(this.individualUserRepo)
      : super(IndividualProfileInitial());

  Future<void> fetchUser(String userId) async {
    emit(IndividualProfileLoading());

    final result = await individualUserRepo.fetchUserProfile(userId);
    result.fold(
      (failure) => emit(IndividualProfileError(failure.errorMassage)),
      (user) => emit(IndividualProfileLoaded(user)),
    );
  }

  Future<void> updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String? avatarUrl,
    required String? points,
  }) async {
    emit(IndividualProfileUpdating());

    final result = await individualUserRepo.updateUserProfile(
      userId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      avatarUrl: avatarUrl,
      points: points,
    );

    result.fold(
      (failure) => emit(IndividualProfileError(failure.errorMassage)),
      (_) => fetchUser(userId), // reload after update
    );
  }
}
