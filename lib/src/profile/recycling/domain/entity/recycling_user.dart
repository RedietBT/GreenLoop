import 'package:equatable/equatable.dart';

class Recycling_User extends Equatable{
  final String id;
  final String? center_name;
  final String? contact_person_first_name;
  final String? contact_person_last_name;
  final String? role;
  final String? email;
  final String? description;
  final String? address;
  final String? avatar_url;
  final String? phone;

  const Recycling_User({
    required this.id,
    this.center_name,
    this.contact_person_first_name,
    this.contact_person_last_name,
    this.role,
    this.email,
    this.description,
    this.address,
    this.avatar_url,
    this.phone,
  });

  @override
  List<Object?> get props => [
        id,
        center_name,
        contact_person_first_name,
        contact_person_last_name,
        role,
        email,
        description,
        address,
        avatar_url,
        phone,
      ];
}
 