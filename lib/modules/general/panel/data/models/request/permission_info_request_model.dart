import 'package:apptalma_v9/modules/general/panel/data/models/request/menu_item_response.dart';

class PermissionInfo {
  final int id;
  final String permissionName;
  final String permissionAbbreviate;
  final String permissionIcon;
  final String? url;
  final List<MenuItemResponse> subItems;
  PermissionInfo({
    required this.id,
    required this.permissionName,
    required this.permissionAbbreviate,
    required this.permissionIcon,
    this.url,
    required this.subItems,
  });

  factory PermissionInfo.fromJson(Map<String, dynamic> json) {
    return PermissionInfo(
      id: json['id'],
      permissionName: json['permissionName'],
      permissionAbbreviate: json['permissionAbbreviate'],
      permissionIcon: json['permissionIcon'],
      url: json['url'],
      subItems: json['subItems'] != null
          ? (json['subItems'] as List)
              .map((e) => MenuItemResponse.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "permissionName": permissionName,
        "permissionAbbreviate": permissionAbbreviate,
        "permissionIcon": permissionIcon,
        "url": url,
        "subItems": subItems.map((e) => e.toJson()).toList(),
      };
  @override
  String toString() {
    return 'PermissionInfo(id: $id, name: $permissionName, url: $url, subItems: ${subItems.length})';
  }
}
