import 'package:greenloop/src/profile/Business/domain/entity/business_user.dart';
import 'package:latlong2/latlong.dart';

class BusinessModel extends Business {
  const BusinessModel({
    required super.id,
    super.business_name,
    super.contact_person_first_name,
    super.contact_person_last_name,
    super.phone_number,
    super.role,
    super.address,
    super.avatarUrl,
    super.points,
    super.email,
    super.description,
    super.location, // Include location in the constructor
    super.no_of_weaste,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    LatLng? parsedLocation;
    final locationString = json['location'] as String?;

    if (locationString != null && locationString.isNotEmpty) {
      final regex = RegExp(r'POINT\(([^ ]+) ([^ ]+)\)');
      final match = regex.firstMatch(locationString);
      if (match != null && match.groupCount == 2) {
        final longitude = double.tryParse(match.group(1)!);
        final latitude = double.tryParse(match.group(2)!);
        if (latitude != null && longitude != null) {
          parsedLocation = LatLng(latitude, longitude);
        }
      }
    }

    return BusinessModel(
      id: json['id'] as String,
      business_name: json['business_name'] as String?,
      contact_person_first_name: json['contact_person_first_name'] as String?,
      contact_person_last_name: json['contact_person_last_name'] as String?,
      phone_number: json['phone'] as String?,
      role: json['role'] as String?,
      address: json['address'] as String?,
      avatarUrl: json['avater_url'] as String?,
      points: json['points'] as int?,
      email: json['email'] as String?,
      description: json['description'] as String?,
      location: parsedLocation,
      no_of_weaste: json['no_of_weaste'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': business_name,
      'contact_person_first_name': contact_person_first_name,
      'contact_person_last_name': contact_person_last_name,
      'phone_number': phone_number,
      'role': role,
      'address': address,
      'avatar_url': avatarUrl,
      'points': points,
      'email': email,
      'description': description,
      'location': location != null
          ? 'SRID=4326;POINT(${location!.longitude} ${location!.latitude})'
          : null,
      'no_of_weaste': no_of_weaste,
    };
  }

  factory BusinessModel.fromEntity(Business entity) {
    return BusinessModel(
      id: entity.id,
      business_name: entity.business_name,
      contact_person_first_name: entity.contact_person_first_name,
      contact_person_last_name: entity.contact_person_last_name,
      phone_number: entity.phone_number,
      role: entity.role,
      address: entity.address,
      avatarUrl: entity.avatarUrl,
      points: entity.points,
      email: entity.email,
      description: entity.description,
      location: entity.location,
      no_of_weaste: entity.no_of_weaste,
    );
  }
}