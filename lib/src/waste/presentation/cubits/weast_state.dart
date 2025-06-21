import 'package:equatable/equatable.dart';
import 'package:greenloop/src/profile/recycling/domain/entity/recycling_user.dart';
import 'package:greenloop/src/waste/domain/entitty/weste.dart';

abstract class WeastState extends Equatable{
  const WeastState();

  @override
  List<Object?> get props => [];
}

class WeastInitial extends WeastState {}

class WeastLoading extends WeastState {}

class WeastInserted extends WeastState {}

class RecyclerLoaded extends WeastState {
  final Recycling_User recyclingUser;
  const RecyclerLoaded(this.recyclingUser);
}

class WeastRequestPickup extends WeastState {}

class WeastLoaded extends WeastState {
  final Weast weast;
  const WeastLoaded(this.weast);
}

class WeastUpdating extends WeastState {}

class WeastError extends WeastState {
  final String message;
  const WeastError(this.message);
}