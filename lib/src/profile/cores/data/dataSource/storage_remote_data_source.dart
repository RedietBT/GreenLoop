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
      final String userId = filePath!; // filePath now contains widget.userId
    if (userId.isEmpty) {
      throw ServerException(message: 'User ID is required for file upload path', statusCode: 400);
    }
    final String fileExtension = file.path.split('.').last;
    final String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    // This is the CRUCIAL part: Constructing the path as 'avatars/userId/uniqueFileName'
    final String storagePath = 'avatars/$userId/$uniqueFileName';

       await supabaseClient.storage
        .from(bucketName)
        .upload(
          storagePath, // Use the structured path
          file,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: false,
          ),
        );

      final String fullPublicUrl = supabaseClient.storage.from(bucketName).getPublicUrl(storagePath);

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