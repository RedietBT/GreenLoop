import 'package:equatable/equatable.dart';

class Business extends Equatable{
  final String id;
  final String business_name;
  final String contact_person_first_name;
  final String contact_person_last_name;
  final String email;
  final String phone_no;
  final String role;
  final String password;

  const Business({
    required this.id,
    required this.business_name,
    required this.contact_person_first_name,
    required this.contact_person_last_name,
    required this.email,
    required this.phone_no,
    required this.role,
    required this.password,
  });

  @override
  List<Object?> get props => [id, business_name, contact_person_first_name, contact_person_last_name, email, phone_no, role, password];

  get contactPersonFirstName => null;
}