import 'package:greenloop/src/profile/Business/domain/entity/business_user.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusinessModel extends Business {
  const BusinessModel({
    required super.id,
    required super.business_name,
    required super.contact_person_first_name,  
    required super.contact_person_last_name,
    required super.phone_number,
    required super.role,
    required super.address,
    required super.email,
    required super.avatarUrl,
    required super.points,
    required super.description,
    required super.location,
  });
  
  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] as String,
      business_name: json['business_name'] as String,
      contact_person_first_name: json['contact_person_first_name'] as String,
      contact_person_last_name: json['contact_person_last_name'] as String,
      phone_number: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? '',
      address: json['address'] as String?,
      email: json['email'] as String? ?? '',
      avatarUrl: json['avater_url'] as String?,
      points: json['points'] as int?,
      description: json['description'] as String?,
      location: json['location'] != null
          ? LatLng(
              json['location']['latitude'] as double,
              json['location']['longitude'] as double,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': business_name,
      'contact_person_first_name': contact_person_first_name,
      'contact_person_last_name': contact_person_last_name,
      'phone': phone_number,
      'role': role,
      'address': address,
      'email': email,
      'avater_url': avatarUrl,
      'points': points,
      'description': description,
      'location': location != null
          ? {
              'latitude': location!.latitude,
              'longitude': location!.longitude,
            }
          : null,
    };
  }
}