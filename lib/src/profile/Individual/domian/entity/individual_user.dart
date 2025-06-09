import 'package:equatable/equatable.dart';

class Individual_User extends Equatable{
  final String id;
  final String? first_name;
  final String? last_name;
  final String? role;
  final String? avatarUrl;
  final int? points;
  final String? email;
  final String? description;

  const Individual_User({
    required this.id,
     this.first_name,
     this.last_name,
     this.role,
     this.avatarUrl,
     this.points,
     this.email,
     this.description,
  });

  @override
  List<Object?> get props => [id, first_name, last_name, role, avatarUrl, points, email, description];

  get eventsJoined => null;

  get badgesEarned => null;

  get treesPlanted => null;

  get achievements => null;
}