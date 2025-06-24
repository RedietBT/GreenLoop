import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class Business extends Equatable {
  final String id;
  final String? business_name;
  final String? contact_person_first_name;
  final String? contact_person_last_name;
  final String? phone_number;
  final String? role;
  final String? address;
  final String? avatarUrl;
  final int? points;
  final String? email;
  final String? description;
  final LatLng? location;
  final int? no_of_weaste;


  const Business({
    required this.id,
    this.business_name,
    this.contact_person_first_name,
    this.contact_person_last_name,
    this.phone_number,
    this.role,
    this.address,
    this.avatarUrl,
    this.points,
    this.email,
    this.description,
    this.location,
    this.no_of_weaste,
  });

  @override
  List<Object?> get props => [
        id,
        business_name,
        contact_person_first_name,
        contact_person_last_name,
        phone_number,
        role,
        address,
        avatarUrl,
        points,
        email,
        description,
        location,
        no_of_weaste,
      ];
}