import 'package:greenloop/src/profile/recycling/domain/entity/recycling_user.dart';
import 'package:latlong2/latlong.dart';

class Recycling_UserModel extends Recycling_User {
  const Recycling_UserModel({
    required super.id,
    super.center_name,
    super.contact_person_first_name,
    super.contact_person_last_name,
    super.role,
    super.email,
    super.description,
    super.address,
    super.avatar_url,
    super.phone,
    super.location,
  });

  factory Recycling_UserModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw const FormatException('Recycling_UserModel.fromJson: Input map is null. Cannot create model from null data.');
    }

    LatLng? parsedLocation;
    final locationString = json['location'] as String?;

    if (locationString != null && locationString.isNotEmpty) {
      final regex = RegExp(r'POINT\\(([^ ]+) ([^ ]+)\\)');
      final match = regex.firstMatch(locationString);
      if (match != null && match.groupCount == 2) {
        final longitude = double.tryParse(match.group(1)!);
        final latitude = double.tryParse(match.group(2)!);
        if (latitude != null && longitude != null) {
          parsedLocation = LatLng(latitude, longitude);
        }
      }
    }

    return Recycling_UserModel(
      id: json['id'] as String,
      center_name: json['center_name'] as String?,
      contact_person_first_name: json['contact_person_first_name'] as String?,
      contact_person_last_name: json['contact_person_last_name'] as String?,
      role: json['role'] as String?,
      email: json['email'] as String?,
      description: json['description'] as String?,
      address: json['address'] as String?,
      avatar_url: json['avater_url'] as String?,
      phone: json['phone'] as String?,
      location: parsedLocation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'center_name': center_name,
      'contact_person_first_name': contact_person_first_name,
      'contact_person_last_name': contact_person_last_name,
      'role': role,
      'email': email,
      'description': description,
      'address': address,
      'avater_url': avatar_url,
      'phone': phone,
      'location': location != null
          ? 'SRID=4326;POINT(${location!.longitude} ${location!.latitude})'
          : null,
    };
  }
} 