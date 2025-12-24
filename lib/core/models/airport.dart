class Airport {
  final int id;
  final String code;

  Airport({
    required this.id,
    required this.code,
  });

  // Deserialización desde JSON
  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      id: json['id'],
      code: json['code'],
    );
  }

  // Serialización a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
    };
  }
}