class UserRewards {
  final String id; 
  final String userId;
  final String rewardId;
  final DateTime redeemedAt;

  const UserRewards({
    required this.id,
    required this.userId,
    required this.rewardId,
    required this.redeemedAt,
  });

  List<Object?> get props => [id, userId, rewardId, redeemedAt];
}