import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class PickupRequest extends Equatable {
  final String id;
  final String userId;
  final String wasteSubmissionId;
  final String recyclingCenterId;
  final String requestStatus;
  final DateTime createdAt;

  final String? wasteType;
  final double? wasteQuantity;
  final LatLng? wasteLocation;
  final String? userName;
  final String? userAvatar;

  const PickupRequest({
    required this.id,
    required this.userId,
    required this.wasteSubmissionId,
    required this.recyclingCenterId,
    required this.requestStatus,
    required this.createdAt,
    this.wasteType,
    this.wasteQuantity,
    this.wasteLocation,
    this.userName,
    this.userAvatar,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        wasteSubmissionId,
        recyclingCenterId,
        requestStatus,
        createdAt,
        wasteType,
        wasteQuantity,
        wasteLocation,
        userName,
        userAvatar,
      ];
} 