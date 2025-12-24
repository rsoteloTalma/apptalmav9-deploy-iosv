class UserRoles {
  final int id;
  final String code;
  final String description;

  UserRoles({
    required this.id,
    required this.code,
    required this.description,
  });

  // Deserialización desde JSON
  factory UserRoles.fromJson(Map<String, dynamic> json) {
    return UserRoles(
      id: json['id'],
      code: json['code'],
      description: json['description'],
    );
  }

  // Serialización a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
    };
  }
}