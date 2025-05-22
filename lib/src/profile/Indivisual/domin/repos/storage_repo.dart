import 'dart:io';
import 'package:greenloop/core/utils/typedefs.dart';

abstract class StorageRepo {
  const StorageRepo();

  ResultFuture<String> uploadFile({
   required String bucketName, 
    String filepath,
    required File file,
});
}