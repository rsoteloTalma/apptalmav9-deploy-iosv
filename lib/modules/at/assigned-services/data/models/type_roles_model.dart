import 'dart:convert';

class TypeRoles {
  final int id;
  final String name;
  final int? processId;

  TypeRoles({
    required this.id,
    required this.name,
    required this.processId,
  });

  factory TypeRoles.fromJson(Map<String, dynamic> json) {
    return TypeRoles(
        id: json['id'] ?? 0,
        name: json['name'] ?? "",
        processId: json['proccessId'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'processId': processId};
  }

  static List<TypeRoles> listFromJson(String str) {
    final data = json.decode(str) as List;
    return data.map((item) => TypeRoles.fromJson(item)).toList();
  }

  static String listToJson(List<TypeRoles> list) {
    final data = list.map((item) => item.toJson()).toList();
    return json.encode(data);
  }
}
