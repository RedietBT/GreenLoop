class Rewards {
  final String? id;
  final String? name;
  final String? points_required;
  final String? redeemed_at;

  const Rewards({
    required this.id,
    required this.name,
    this.points_required,
    required this.redeemed_at,
  });

  factory Rewards.fromMap(Map<String, dynamic> map) {
    return Rewards(
      id: map['id'],
      name: map['name'],
      points_required: map['points_required'],
      redeemed_at: map['redeemed_at'],
    );
  }
}