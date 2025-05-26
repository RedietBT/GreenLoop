import 'package:greenloop/src/profile/Individual/domian/entity/rewards.dart';

class RewardsModel extends Rewards {
  const RewardsModel({
  required super.id,
  required super.name,
  required super.points_required,
  });

 factory RewardsModel.fromJson(Map<String, dynamic> json) {
    return RewardsModel(
      id: json['id'] as String,
      name: json['name'] as String,
      points_required: json['points_required'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['points_required'] = points_required;
    return data;
  }
}