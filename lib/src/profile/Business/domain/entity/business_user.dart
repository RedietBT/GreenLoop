import 'package:equatable/equatable.dart';

class Business extends Equatable{
  final String id;
  final String business_name;
  final String contact_person_first_name;
  final String contact_person_last_name;
  final String phone_number;
  final String role;
  final String? address;
  final String? avatarUrl;
  final String? points;
  final String? email;
  final String? description;

  const Business({
    required this.id,
    required this.business_name,
    required this.contact_person_first_name,
    required this.contact_person_last_name,
    required this.phone_number,
    required this.role,
    required this.address,
    required this.avatarUrl,
    required this.points,
    required this.email,
    required this.description,
  });
   

  @override

  List<Object?> get props => [id, business_name, contact_person_first_name, contact_person_last_name, phone_number, address, role, avatarUrl, points, email, description];
}