import 'package:greenloop/src/waste/domain/entitty/weste.dart';

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
}