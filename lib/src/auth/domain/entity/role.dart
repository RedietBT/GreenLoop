class Role {
  final String id;
  final String name;

 const Role({required this.id, required this.name});

  factory Role.fromMap(Map<String, dynamic> map) {
    return Role(
      id: map['id'],
      name: map['name'],
    );
  }
}
