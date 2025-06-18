import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/auth/domain/repos/auth_repo.dart';
import 'package:greenloop/src/profile/Business/domain/repo/business_repo.dart';
import 'package:greenloop/src/profile/Business/presentation/cubits/business_profile_state.dart';
import 'package:greenloop/src/profile/cores/domain/repos/storage_repo.dart';
import 'package:greenloop/src/auth/domain/usecases/signOut.dart';
import 'package:flutter/material.dart';

class BusinessProfileCubit extends Cubit<BusinessProfileState> {
  final BusinessRepo businessRepo;
  final StorageRepo storageRepo;

  BusinessProfileCubit({
    required this.businessRepo,
    required this.storageRepo,
  }) : super(const BusinessProfileInitial());

  Future<void> fetchUserProfile(String userId) async {
    emit(const BusinessProfileLoading());
    final result = await businessRepo.fetchUserProfile(userId);

    result.fold(
      (failure) => emit(BusinessProfileError(failure.message)),
      (business) => emit(BusinessProfileLoaded(business)),
    );
  }

  Future<void> updateProfile({
  required String userId,
  required Map<String, dynamic> data, 
}) async {
  emit(BusinessProfileUpdating());
  
  final result = await businessRepo.updateUserProfile(
    userId,
    data: data,
  );

  result.fold(
      (failure) => emit(BusinessProfileError(failure.errorMassage)),
      (updatedUser) { 
        emit(BusinessProfileLoaded(updatedUser)); 
      },
    );
}

  Future<String> uploadFile({
    required String bucketName,
    String? filepath,
    required File file,
  }) async {
    emit(const BusinessProfileUploadingAvatar());

    final result = await storageRepo.uploadFile(
      bucketName: bucketName,
      filepath: filepath,
      file: file,
    );

    return result.fold(
      (failure) {
        emit(BusinessProfileError(failure.message));
        throw Exception(failure.message);
      },
      (publicUrl) {
        return publicUrl;
      },
    );
  }

  Future<void> signOut(BuildContext context, AuthRepo authRepo) async {
    // Use the injected signOut usecase if available, otherwise create it here
    final signOutUsecase = Signout(authRepo);
    await signOutUsecase.call();
    // After sign out, navigate to login
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
