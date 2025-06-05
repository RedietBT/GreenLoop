import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/profile/Business/domain/repo/business_repo.dart';
import 'package:greenloop/src/profile/Business/presentation/cubits/business_profile_state.dart';
import 'package:greenloop/src/profile/cores/domain/repos/storage_repo.dart';

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
      (business) => emit(BusinessProfileLoaded(business: business)),
    );
  }

  Future<void> updateProfile({
    required String userId,
    required String business_name,
    required String contact_person_first_name,
    required String contact_person_last_name,
    required String phone_number,
    required String? address,
    required String email,
    required String? avatarUrl,
    required String? points,
    required String? description,
  }) async {
    emit(const BusinessProfileUpdating());
    final result = await businessRepo.updateUserProfile(
      userId,
      business_name: business_name,
      contact_person_first_name: contact_person_first_name,
      contact_person_last_name: contact_person_last_name,
      phone_number: phone_number,
      address: address,
      email: email,
      avatarUrl: avatarUrl,
      points: points,
      description: description,
    );

    result.fold(
      (failure) => emit(BusinessProfileError(failure.message)),
      (_) => fetchUserProfile(userId),
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
}
