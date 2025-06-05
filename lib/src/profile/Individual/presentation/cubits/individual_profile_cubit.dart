import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/profile/Individual/domian/repos/individual_user_repo.dart';
import 'package:greenloop/src/profile/cores/domain/repos/storage_repo.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_state.dart';

class IndividualProfileCubit extends Cubit<IndividualProfileState> {
  final IndividualUserRepo individualUserRepo;
  final StorageRepo storageRepo;

  IndividualProfileCubit(this.individualUserRepo, this.storageRepo)
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
    String? firstName, // <--- Made nullable
    String? lastName,  // <--- Made nullable
    String? email,     // <--- Made nullable
    String? avatarUrl,
    String? points,
    String? description,
  }) async {
    emit(IndividualProfileUpdating());

    // Call the repository with only the non-null (changed) values.
    // The repository's implementation of updateUserProfile must be able to handle nulls
    // by not updating those specific columns in the database.
    final result = await individualUserRepo.updateUserProfile(
      userId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      avatarUrl: avatarUrl,
      points: points, // Assuming points might be updated separately or kept null
      description: description,
    );

    result.fold(
      (failure) => emit(IndividualProfileError(failure.errorMassage)),
      (_) => fetchUser(userId), // Re-fetch user to reflect changes
    );
  }

  Future<String> uploadFile({
    required String bucketName,
    String? filepath,
    required File file,
  }) async {
    final result = await storageRepo.uploadFile(
      bucketName: bucketName,
      filepath: filepath,
      file: file,
    );

    return result.fold(
      (failure) => throw Exception(failure.errorMassage),
      (publicUrl) => publicUrl,
    );
  }
}