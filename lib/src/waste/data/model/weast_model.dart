import 'package:greenloop/src/waste/domain/entitty/weste.dart';
import 'package:latlong2/latlong.dart';

class WeastModel extends Weast{

  const WeastModel({
    required super.id,
    super.weastId,
    super.userId,
    super.type,
    super.quantity,
    super.location,
    super.recyclingCenterId,
    super.requestStatus,
  });

  factory WeastModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw const FormatException('WeastModel.fromJson: Input map is null. Cannot create model from null data.');
    }

    return WeastModel(
      id: json['id'] as String,
      weastId: json['weast-submissionID'] as String?,
      userId: json['userID'] as String?,
      type: json['type'] as String?,
      quantity: json['quantity'] as String?,
      location: json['location'] as String?,
      recyclingCenterId: json['recycling-centerID'] as String?,
      requestStatus: json['request-status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weast-submissionID': weastId,
      'userID': userId,
      'type': type,
      'quantity': quantity,
      'location': location,
      'recycling-centerID': recyclingCenterId,
      'request-status': requestStatus,
    };
  }

  // Helper method to format location for database storage
  static String formatLocationForDatabase(LatLng? location) {
    if (location == null) return '';
    return 'SRID=4326;POINT(${location.longitude} ${location.latitude})';
  }

  // Helper method to parse location from database format
  static LatLng? parseLocationFromDatabase(String? locationString) {
    if (locationString == null || locationString.isEmpty) return null;
    
    final regex = RegExp(r'POINT\(([^ ]+) ([^ ]+)\)');
    final match = regex.firstMatch(locationString);
    if (match != null && match.groupCount == 2) {
      final longitude = double.tryParse(match.group(1)!);
      final latitude = double.tryParse(match.group(2)!);
      if (latitude != null && longitude != null) {
        return LatLng(latitude, longitude);
      }
    }
    return null;
  }
}