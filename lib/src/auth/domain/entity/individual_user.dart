import 'package:equatable/equatable.dart';

class IndividualUser extends Equatable{
  final String id;
  final String first_name;
  final String last_name;
  final String email;
  final String role;
  final String password;

  const IndividualUser({
    required this.id,
    required this.first_name,
    required this.last_name,
    required this.email,
    required this.role,
    required this.password,
  });

  @override
  List<Object?> get props => [id, first_name, last_name, email, role, password];
}