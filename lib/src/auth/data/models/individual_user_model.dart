import 'package:greenloop/src/auth/domain/entity/individual_user.dart';

class IndividualUserModel extends IndividualUser {
  const IndividualUserModel({
    required super.id,
    required super.first_name,
    required super.last_name,
    required super.email,
    required super.role,
    required super.password,
  });

  factory IndividualUserModel.fromJson(Map<String, dynamic> json) {
    return IndividualUserModel(
      id: json['id'] as String,
      first_name: json['first_name'] as String,
      last_name: json['last_name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      password: json['password'] as String,
    );
  }
}