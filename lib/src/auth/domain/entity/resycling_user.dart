import 'package:equatable/equatable.dart';

class ResyclingUser extends Equatable{
  final String id;
  final String center_name;
  final String contact;
  final String email;
  final String role;
  final String password;

  const ResyclingUser({
    required this.id,
    required this.center_name,
    required this.contact,
    required this.email,
    required this.role,
    required this.password,
  });

  @override
  List<Object?> get props => [id, center_name, contact, email, role, password];
}