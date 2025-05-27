import 'package:equatable/equatable.dart';

class Rewards extends Equatable {
  final String id;
  final String name;
  final int points_required;


  const Rewards({
    required this.id,
    required this.name,
    required this.points_required,
  });

  @override
  List<Object?> get props => [id, name, points_required];

}