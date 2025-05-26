import 'package:greenloop/src/profile/Individual/domian/entity/user_rewards.dart';

class UserRewardsModel extends UserRewards{

  const UserRewardsModel({
    required super.id,
    required super.userId,
    required super.rewardId,
    required super.redeemedAt,
  });

  factory UserRewardsModel.fromJson(Map<String, dynamic> json) {
    return UserRewardsModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      rewardId: json['reward_id'] as String,
      redeemedAt: DateTime.parse(json['redeemed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'reward_id': rewardId,
      'redeemed_at': redeemedAt.toIso8601String(),
    };
  }
}