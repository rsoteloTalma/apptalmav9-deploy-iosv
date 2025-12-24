import 'dart:developer';
import 'package:dio/dio.dart';

import 'package:apptalma_v9/core/models/user.dart';
import 'package:apptalma_v9/core/network/network.dart';
import 'package:apptalma_v9/modules/general/panel/data/models/request/menu_item_response.dart';
import 'package:apptalma_v9/modules/general/panel/data/models/request/permission_info_request_model.dart';
import 'package:apptalma_v9/modules/general/panel/data/models/request/airport_info_request_model.dart';

final ApiService apiService = ApiService();

class PanelController {
  late final User user;
  PanelController(this.user);

  Future<List<PermissionInfo>> getPermissions(int id) async {
    final permissionIds = user.roles.map((role) => role.id).toList();

    if (permissionIds.isEmpty) {
      log("El usuario no tiene roles");
      return [];
    }

    try {
      final response = await apiService.request<Map<String, dynamic>>(
        endpoint: "Authenticator/GetMenu",
        method: "POST",
        data: permissionIds,
      );

      final dataList = response["data"] as List<dynamic>;

      List<PermissionInfo> permissions = [];

      for (final item in dataList) {
        final menuItem = item as Map<String, dynamic>;
        final permissionArray = menuItem["permissions"] as List<dynamic>?;

        if (permissionArray != null && permissionArray.isNotEmpty) {
          final permission = permissionArray.first as Map<String, dynamic>;

          final List<MenuItemResponse> subItems =
              (menuItem["subItems"] as List<dynamic>?)
                      ?.map((e) => MenuItemResponse.fromJson(e))
                      .toList() ??
                  [];

          permissions.add(PermissionInfo(
            id: permission["id"],
            permissionName: menuItem["text"] ?? "",
            permissionAbbreviate: menuItem["text"] ?? "",
            permissionIcon: menuItem["icon"] ?? "",
            url: menuItem["url"], // ✅ CAMBIO AQUÍ
            subItems: subItems,
          ));
        }
      }

      return permissions;
    } catch (e) {
      log("Error en getPermissions: $e");
      return [];
    }
  }

  Future<AirportInfo> getStation(int id) async {
    try {
      final response = await apiService.request(
        endpoint: "GENERAL/GetAirportInfo",
        method: "GET",
        queryParameters: {
          "airportId": id,
        },
      );

      if (response != null) {
        return AirportInfo.fromJson(response);
      } else {
        throw Exception("Respuesta vacía");
      }
    } on DioException catch (e) {
      print("Error en la API: ${e.response?.statusCode} - ${e.response?.data}");
      rethrow;
    } catch (e) {
      print("Error desconocido: $e");
      rethrow;
    }
  }

  Future<void> getMenu() async {
    log("getMenu: iniciando petición...");

    try {
      final permissionIds = user.roles.map((e) => e.id).toList();

      if (permissionIds.isEmpty) {
        log("El usuario no tiene permisos.");
        return;
      }

      final response = await apiService.request(
        endpoint: "api/GetMenu",
        method: "POST",
        data: permissionIds,
      );

      log("Menú obtenido: $response");
    } catch (e) {
      if (e is DioException && e.response != null) {
        log("Error en la API: ${e.response?.statusCode} - ${e.response?.data}");
      } else {
        log("Error desconocido: $e");
      }
    }
  }
}
