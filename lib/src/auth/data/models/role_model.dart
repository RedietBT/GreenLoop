import 'package:greenloop/src/auth/domain/entity/role.dart';
class RoleModel extends Role {
  const RoleModel({
    required super.id, 
    required super.name
    });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}