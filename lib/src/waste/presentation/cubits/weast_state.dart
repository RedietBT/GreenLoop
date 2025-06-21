import 'package:greenloop/src/waste/domain/entitty/weste.dart';

abstract class WeastState {}

class WeastInitial extends WeastState {}

class WeastLoading extends WeastState {}

class WeastLoaded extends WeastState {
  final Weast waste;
  WeastLoaded(this.waste);
}

class WeastUpdating extends WeastState {}

class WeastError extends WeastState {
  final String message;
  WeastError(this.message);
}