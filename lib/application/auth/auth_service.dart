import 'package:greenloop/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final AuthRepository repo;

  AuthService(this.repo);

  Future<AuthResponse> siginInWithEmailAndPassword(String email, String password) => repo.siginInWithEmailAndPassword(email, password);
  Future<AuthResponse> sigUpInWithEmailAndPassword(String email, String password, String firstName, String lastName, String? role) => repo.sigUpInWithEmailAndPassword(email, password, firstName, lastName, role);
  Future<void> signOut() => repo.signOut();
  Future<void> insertUserProfile({required String id, required String firstName, required String lastName, required String email, required String role}) => repo.insertUserProfile(id: id, firstName: firstName, lastName: lastName, email: email, role: role);
  Future<void> insertIntoRecyclinTable({required String id, required String centerName, required String contactInfo, required String email, required String role}) => repo.insertIntoRecyclinTable(id: id, centerName: centerName, contactInfo: contactInfo, email: email, role: role);
  String? getCurrentUserEmail() => repo.getCurrentUserEmail();
  Future<List<Map<String, dynamic>>> getRoles() => repo.getRoles();
}