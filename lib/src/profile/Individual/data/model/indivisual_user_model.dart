import 'package:greenloop/src/profile/Individual/domian/entity/individual_user.dart';

class Individual_UserModel extends Individual_User {
  const Individual_UserModel({
    required super.id,
     super.first_name,
     super.last_name,
     super.role,
     super.avatarUrl,
     super.points,
     super.email,
     super.description,
  });

  factory Individual_UserModel.fromJson(Map<String, dynamic> json) {
    return Individual_UserModel(
      id: json['id'] as String,
      first_name: json['first_name'] as String,
      last_name: json['last_name'] as String,
      role: json['role'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      points: json['points'] as String?,
      email: json['email'] as String,
      description: json['description'] as String?,
    );
  }
}