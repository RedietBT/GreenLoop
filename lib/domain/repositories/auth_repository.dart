import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<AuthResponse> siginInWithEmailAndPassword(String email, String password);
  Future<AuthResponse> sigUpInWithEmailAndPassword(String email, String password, String firstName, String lastName, String? role);
  Future<void> signOut();
  Future<void> insertUserProfile({
  required String id,
  required String firstName,
  required String lastName,
  required String email,
  required String role,
  });
String? getCurrentUserEmail();
Future<List<Map<String, dynamic>>> getRoles();
}
