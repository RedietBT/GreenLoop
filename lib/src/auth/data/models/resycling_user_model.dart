import 'package:greenloop/src/auth/domain/entity/resycling_user.dart';

class ResyclingUserModel extends ResyclingUser {
  const ResyclingUserModel({
    required super.id,
    required super.center_name,
    required super.contact,
    required super.email,
    required super.role,
    required super.password,
  });

  factory ResyclingUserModel.fromJson(Map<String, dynamic> json) {
    return ResyclingUserModel(
      id: json['id'] as String,
      center_name: json['center_name'] as String,
      contact: json['contact'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      password: json['password'] as String,
    );
  }
}