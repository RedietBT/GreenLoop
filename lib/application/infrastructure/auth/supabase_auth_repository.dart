import 'package:greenloop/application/Repository/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

// Insert user data to profile table
  @override
  Future<void> insertUserProfile({required String id, required String firstName, required String lastName, required String email, required String role}) async{await _supabase.from('profile').insert({
        'id': id,
        'frist_name': firstName,
        'last_name': lastName,
        'email': email,
        'role': role,
      });
  }
// Insert into Recycling center
@override
  Future<void> insertIntoRecyclinTable({required String id, required String centerName, required String contactInfo, required String email, required String role}) async{await _supabase.from('recycling_center').insert({
        'id': id,
        'center_name': centerName,
        'contact': contactInfo,
        'email': email,
        'role': role,
      });
  }

//Get user email
  @override
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
}

//Get type of roles from role table
  @override
  Future<List<Map<String, dynamic>>> getRoles() async {
    final response = await _supabase.rpc('get_roles');
    return List<Map<String, dynamic>>.from(response as List<dynamic>);
  }
  
// signing up with email and password and metadata
@override
  Future<AuthResponse> sigUpInWithEmailAndPassword(String email, String password, String firstName, String lastName, String? role) async {
  return await _supabase.auth.signUp(
    email: email,
    password: password,
    data: {
      'frist_name': firstName,
      'last_name': lastName,
      'role': role,
    },
  );
}

// signing up with email and password and metadata
  @override
  Future<AuthResponse> siginInWithEmailAndPassword(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  // signing out
  @override
  Future<void> signOut() => throw UnimplementedError();
}
