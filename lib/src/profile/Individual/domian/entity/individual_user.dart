import 'package:equatable/equatable.dart';

class Individual_User extends Equatable{
  final String id;
  final String first_name;
  final String last_name;
  final String role;
  final String? avatarUrl;
  final String? points;
  final String? email;
  final String? description;

  const Individual_User({
    required this.id,
    required this.first_name,
    required this.last_name,
    required this.role,
    required this.avatarUrl,
    required this.points,
    required this.email,
    required this.description,
  });

  @override
  List<Object?> get props => [id, first_name, last_name, role, avatarUrl, points, email, description];
}