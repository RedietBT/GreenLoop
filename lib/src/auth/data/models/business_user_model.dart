import 'package:greenloop/src/auth/domain/entity/business.dart';

class BusinessUserModel extends Business{

  const BusinessUserModel({
    required super.id,
    required super.business_name,
    required super.contact_person_first_name,
    required super.contact_person_last_name,
    required super.email,
    required super.phone_no,
    required super.role,
    required super.password,
  });

  factory BusinessUserModel.fromJson(Map<String, dynamic> json) {
    return BusinessUserModel(
      id: json['id'] as String,
      business_name: json['business_name'] as String,
      contact_person_first_name: json['contact_person_first_name'] as String,
      contact_person_last_name: json['contact_person_last_name'] as String,
      email: json['email'] as String,
      phone_no: json['phone_no'] as String,
      role: json['role'] as String? ?? 'business',
      password: json['password'] as String,
    );
  }
}