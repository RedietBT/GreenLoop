import 'package:greenloop/src/pickup_request/domain/entities/pickup_request.dart';
import 'package:latlong2/latlong.dart';

class PickupRequestModel extends PickupRequest {
  const PickupRequestModel({
    required super.id,
    required super.userId,
    required super.wasteSubmissionId,
    required super.recyclingCenterId,
    required super.requestStatus,
    required super.createdAt,
    super.wasteType,
    super.wasteQuantity,
    super.wasteLocation,
    super.userName,
    super.userAvatar,
  });

  factory PickupRequestModel.fromMap(Map<String, dynamic> map) {
    LatLng? location;
    final locationString = map['waste_location'] as String?;
    if (locationString != null && locationString.isNotEmpty) {
      final regex = RegExp(r'POINT\(([^ ]+) ([^ ]+)\)');
      final match = regex.firstMatch(locationString);
      if (match != null && match.groupCount == 2) {
        final longitude = double.tryParse(match.group(1)!);
        final latitude = double.tryParse(match.group(2)!);
        if (latitude != null && longitude != null) {
          location = LatLng(latitude, longitude);
        }
      }
    }

    final rawQuantity = map['waste_quantity'];
    double? parsedQuantity;
    if (rawQuantity is num) {
      parsedQuantity = rawQuantity.toDouble();
    } else if (rawQuantity is String) {
      parsedQuantity = double.tryParse(rawQuantity);
    }

    return PickupRequestModel(
      id: map['id'] as String,
      userId: map['userID'] as String,
      wasteSubmissionId: map['waste-submissionID'] as String,
      recyclingCenterId: map['recycling-centerID'] as String,
      requestStatus: map['request-status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      wasteType: map['waste_type'] as String?,
      wasteQuantity: parsedQuantity,
      wasteLocation: location,
      userName: map['user_name'] as String?,
      userAvatar: map['user_avatar'] as String?,
    );
  }
} 