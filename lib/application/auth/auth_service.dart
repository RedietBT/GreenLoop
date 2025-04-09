import 'dart:core' as core;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:core';


class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  //sigining in with email and password
  Future<AuthResponse> siginInWithEmailAndPassword(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

// signing up with email and password and metadata
Future<AuthResponse> sigUpInWithEmailAndPassword(String email, String password, String firstName, String lastName) async {
  return await _supabase.auth.signUp(
    email: email,
    password: password,
    data: {
      'frist_name': firstName,
      'last_name': lastName,
    },
  );
}

  //signing out
Future<void> signOut() async {
   await _supabase.auth.signOut();
  }
  //Get user email
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
}
// Insert user data to profile table
Future<void> insertUserProfile({
  required String id,
  required String firstName,
  required String lastName,
  required String email,
}) async {
  await _supabase.from('profile').insert({
    'id': id, // ✅ Use the user's id from auth.users
    'frist_name': firstName,
    'last_name': lastName,
    'email': email,
  });
}

// Get user data from profile table

//Get type of roles from role table
Future<core.List<Map<String, dynamic>>> getRoles() async {
  final response = await _supabase.rpc('get_roles');
   return List<Map<String, dynamic>>.from(response as core.List<dynamic>);
}
}
