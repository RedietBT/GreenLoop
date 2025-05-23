import 'dart:io';

import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/Indivisual/domian/repos/storage_repo.dart';

class UploadFile {
  final StorageRepo storageRepo;

  const UploadFile({required this.storageRepo});

  ResultFuture<String> call(String bucketName, String filepath, File file) {
    return storageRepo.uploadFile(
      bucketName: bucketName,
      filepath: filepath,
      file: file,
    );
  }
}