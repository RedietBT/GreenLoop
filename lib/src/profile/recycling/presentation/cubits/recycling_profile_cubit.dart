import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/profile/recycling/domain/repos/recycling_user_repo.dart';
import 'package:greenloop/src/profile/cores/domain/repos/storage_repo.dart';
import 'package:greenloop/src/profile/recycling/presentation/cubits/recycling_profile_state.dart';

class RecyclingProfileCubit extends Cubit<RecyclingProfileState> {
  final RecyclingUserRepo recyclingUserRepo;
  final StorageRepo storageRepo;

  RecyclingProfileCubit(this.recyclingUserRepo, this.storageRepo)
      : super(RecyclingProfileInitial());

  Future<void> fetchUser(String userId) async {
    emit(RecyclingProfileLoading());

    final result = await recyclingUserRepo.fetchUserProfile(userId);
    result.fold(
      (failure) => emit(RecyclingProfileError(failure.errorMassage)),
      (user) => emit(RecyclingProfileLoaded(user)),
    );
  }

  Future<void> updateProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    emit(RecyclingProfileUpdating());

    final result = await recyclingUserRepo.updateUserProfile(
      userId: userId,
      data: data,
    );

    result.fold(
      (failure) => emit(RecyclingProfileError(failure.errorMassage)),
      (updatedUser) {
        emit(RecyclingProfileLoaded(updatedUser));
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