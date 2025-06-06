// src/profile/Individual/data/models/individual_user_model.dart

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

  // CRITICAL FIX 1: Make the 'json' input parameter nullable
  factory Individual_UserModel.fromJson(Map<String, dynamic>? json) {
    // CRITICAL FIX 2: Explicitly handle if the entire JSON map is null
    if (json == null) {
      throw const FormatException('Individual_UserModel.fromJson: Input map is null. Cannot create model from null data.');
    }

    return Individual_UserModel(
      id: json['id'] as String, 
      first_name: json['first_name'] as String?, 
      last_name: json['last_name'] as String?,  
      role: json['role'] as String?,             
      avatarUrl: json['avatar_url'] as String?,
      points: json['points'] as int?,
      email: json['email'] as String?,     
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': first_name,
      'last_name': last_name,
      'role': role,
      'avatar_url': avatarUrl, 
      'points': points,
      'email': email,
      'description': description,
    };
  }
}