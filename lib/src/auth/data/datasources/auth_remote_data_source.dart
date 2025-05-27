import 'package:greenloop/core/errors/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  const AuthRemoteDataSource();

  get client => null;

  Future<AuthResponse> signInWithEmailAndPassword(String email, String password);

  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
    String firstName,
    String lastName,
    String? role,
  );

  Future<void> signOut();

  Future<String?> getCurrentUserEmail();
   Future<String?> getCurrentUserId();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient client;

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<AuthResponse> signInWithEmailAndPassword(String email, String password) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
    String firstName,
    String lastName,
    String? role,
  ) async {
    final res = await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'role': role,
      },
    );

    final user = res.user;

    if (user == null) {
      throw Exception("Failed to register user: Supabase returned null user");
    }

    return user; 
  }

  @override
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  @override
  Future<String?> getCurrentUserEmail() async {
    final session = client.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

   @override
  Future<String?> getCurrentUserId() async {
    try {
      return client.auth.currentUser?.id; // Directly return the ID string
    } on AuthException catch (e) {
      throw ServerException(message: e.message, statusCode: int.tryParse(e.statusCode ?? '')  ?? 500);
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }
}
