import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

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
  final LatLng? location;

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
    this.location,
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
        location,
      ];
}
 