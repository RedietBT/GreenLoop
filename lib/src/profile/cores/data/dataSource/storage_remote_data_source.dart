import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:greenloop/core/errors/exceptions.dart';


abstract class StorageRemoteDataSource {
  const StorageRemoteDataSource();

  Future<String> uploadFile({
    required String bucketName,
    String? filePath,
    required File file,
  });
}

class StorageRemoteDataSourceImpl implements StorageRemoteDataSource {
  final SupabaseClient supabaseClient;

  const StorageRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<String> uploadFile({
    required String bucketName,
    String? filePath, 
    required File file,
  }) async {
    try {
      final String path = filePath ?? 'uploads/${DateTime.now().microsecondsSinceEpoch}-${file.path.split('/').last}';

      await supabaseClient.storage
          .from(bucketName).upload(
            path,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      final String fullPublicUrl = supabaseClient.storage.from(bucketName).getPublicUrl(path);

      return fullPublicUrl;
    } on StorageException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.statusCode ?? '') ?? 500, 
      );
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }
}