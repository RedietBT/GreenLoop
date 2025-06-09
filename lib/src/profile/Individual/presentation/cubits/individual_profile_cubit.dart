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
  required Map<String, dynamic> data, 
}) async {
  emit(IndividualProfileUpdating());
  
  final result = await individualUserRepo.updateUserProfile(
    userId,
    data: data,
  );

  result.fold(
      (failure) => emit(IndividualProfileError(failure.errorMassage)),
      (updatedUser) { 
        emit(IndividualProfileLoaded(updatedUser)); 
      },
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