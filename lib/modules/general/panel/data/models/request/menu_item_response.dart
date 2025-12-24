class MenuItemResponse {
  final int id;
  final String code;
  final String text;
  final String icon;
  final String url;

  MenuItemResponse({
    required this.id,
    required this.code,
    required this.text,
    required this.icon,
    required this.url,
  });

  factory MenuItemResponse.fromJson(Map<String, dynamic> json) {
    return MenuItemResponse(
      id: json["id"],
      code: json["code"],
      text: json["text"],
      icon: json["icon"] ?? "",
      url: json["url"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "code": code,
      "text": text,
      "icon": icon,
      "url": url,
    };
  }
}
