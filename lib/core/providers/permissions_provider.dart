import 'package:flutter/material.dart';
import 'package:apptalma_v9/modules/general/panel/data/models/request/permission_info_request_model.dart';

class PermissionsProvider extends ChangeNotifier {
  List<PermissionInfo> _permissions = [];

  List<PermissionInfo> get permissions => _permissions;

  /// Cargar permisos completos
  void setPermissions(List<PermissionInfo> permissions) {
    _permissions = permissions;
    notifyListeners();
  }

  /// Agrupar por `permissionAbbreviate`
  Map<String, List<PermissionInfo>> get groupedByAbbreviation {
    final Map<String, List<PermissionInfo>> grouped = {};
    for (var perm in _permissions) {
      grouped.putIfAbsent(perm.permissionAbbreviate, () => []);
      grouped[perm.permissionAbbreviate]!.add(perm);
    }
    return grouped;
  }

  /// Obtener lista única de grupos
  List<String> get groups => groupedByAbbreviation.keys.toList();
}
