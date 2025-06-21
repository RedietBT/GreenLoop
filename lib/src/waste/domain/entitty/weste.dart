import 'package:equatable/equatable.dart';

class Weast extends Equatable {
  final String id;
  final String? weastId;
  final String? userId;
  final String? type;
  final String? quantity;
  final double? location;
  final String? recyclingCenterId;
  final String? requestStatus;

  const Weast({
    required this.id,
     this.weastId,
     this.userId,
     this.type,
     this.quantity,
     this.location,
     this.recyclingCenterId,
     this.requestStatus,
  });

  @override
  List<Object> get props => [
        id,
        userId ?? '',
        type ?? '',
        quantity ?? '',
        location ?? '',
        weastId ?? '',
        recyclingCenterId ?? '',
        requestStatus ?? ''
      ];
}