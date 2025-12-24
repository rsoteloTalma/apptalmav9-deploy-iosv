import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:apptalma_v9/core/network/network.dart';

import 'package:apptalma_v9/modules/at/assigned-services/data/models/add_resource_model.dart';
import 'package:apptalma_v9/modules/at/assigned-services/data/models/resource_info_model.dart';
import 'package:apptalma_v9/modules/at/assigned-services/data/models/validation_resource_model.dart';
import 'package:apptalma_v9/modules/at/assigned-services/data/models/ground_services_model.dart';
import 'package:apptalma_v9/modules/at/assigned-services/data/models/type_roles_model.dart';
import 'package:apptalma_v9/modules/at/assigned-services/data/models/resource_by_service_model.dart';

class GroundServicesController {
  final ApiService apiService = ApiService();

  // >> get flights list
  Future<List<GroundServices>> getGroundServicesToUser(
      String employeeId) async {
    try {
      final response = await apiService.request<Map<String, dynamic>>(
        endpoint: "/APP/AT/GroundServicesXUser",
        method: "GET",
        queryParameters: {
          "employeeId": employeeId,
        },
      );

      final dataList = response["listGroundServices"] as List<dynamic>?;

      if (dataList == null || dataList.isEmpty) {
        log("No se encontraron servicios para el usuario.");
        return [];
      }

      final servicios =
          dataList.map((item) => GroundServices.fromJson(item)).toList();

      log("Servicios obtenidos: ${servicios.length}");
      return servicios;
    } on DioException catch (e) {
      log("Error en la API: ${e.response?.statusCode} - ${e.response?.data}");
      return [];
    } catch (e) {
      log("Error inesperado en getGroundServicesToUser: $e");
      return [];
    }
  }

  // >> get human resources
  Future<List<ResourceByService>> getResourceByService(
      String serviceHeaderId) async {
    if (serviceHeaderId.isEmpty) {
      log("El parámetro serviceHeaderId es nulo o inválido.");
      return [];
    }

    try {
      int cioCode = int.parse(serviceHeaderId);

      // esta retornando la lista sin el Response
      final response = await apiService.request<List<dynamic>>(
        endpoint: "APP/AT/GetFlightResources",
        method: "POST",
        data: {"serviceHeaderId": cioCode, "processName": "RAMPA"},
      );

      final data =
          response.map((item) => ResourceByService.fromJson(item)).toList();

      log("resource by service obtenidos: ${data.length}");
      return data;
    } on DioException catch (e) {
      log("Error en la API: ${e.response?.statusCode} - ${e.response?.data}");
      return [];
    } catch (e) {
      log("Error inesperado en getResourceByService: $e");
      return [];
    }
  }

// >> get flight resources (roles)
  Future<List<TypeRoles>> getFlightRoles() async {
    try {
      // esta retornando la lista sin el Response
      final response = await apiService.request<List<dynamic>>(
        endpoint: "/APP/AT/GetAllRolesAsync",
        method: "GET",
        data: [],
      );

      final data = response.map((item) => TypeRoles.fromJson(item)).toList();
      return data;
    } on DioException catch (e) {
      log("Error en la API: ${e.response?.statusCode} - ${e.response?.data}");
      return [];
    } catch (e) {
      log("Error inesperado en getFlightRoles: $e");
      return [];
    }
  }

  // >> save human resources
  Future<ResourceInformation> infoResources(Map<String, dynamic> params) async {
    try {
      final response = await apiService.request<Map<String, dynamic>>(
        endpoint: "/APP/AT/GetResourceInformationHRV",
        method: "POST",
        data: params,
      );

      final dataMap = response["response"] as Map<String, dynamic>;
      final data = ResourceInformation.fromJson(dataMap);
      print("infoResources");
      return data;
    } on DioException catch (e) {
      log("Error en la API: ${e.response?.statusCode} - ${e.response?.data}");
      return ResourceInformation.empty();
    } catch (e) {
      log("Error inesperado en getResourceInformationHRV: $e");
      return ResourceInformation.empty();
    }
  }

  // >> validation simultaneity
  Future<ValidationResource> validateSimultaneity(
      Map<String, dynamic> params) async {
    try {
      final response = await apiService.request<Map<String, dynamic>>(
        endpoint: "/APP/AT/ValidateResourceQR",
        method: "POST",
        data: params,
      );

      final dataMap = response;
      final data = ValidationResource.fromJson(dataMap);
      print("validateSimultaneity");
      return data;
    } on DioException catch (e) {
      log("Error en la API: ${e.response?.statusCode} - ${e.response?.data}");
      return {} as ValidationResource;
    } catch (e) {
      log("Error inesperado en getResourceInformationHRV: $e");
      return {} as ValidationResource;
    }
  }

  // >> add resource
  Future<Object> addResource(AddResource params) async {
    print("addResource");
    try {
      final response = await apiService.request(
        endpoint: "/APP/AT/SaveHumanResource",
        method: "POST",
        data: params,
      );
      return response;
    } on DioException catch (e) {
      log("Error en la API: ${e.response?.statusCode} - ${e.response?.data}");
      return {};
    } catch (e) {
      log("Error inesperado en SaveHumanResource: $e");
      return {};
    }
  }

  // >> delete resource
  Future<Object> deleteResource(Map<String, dynamic> params) async {
    print("deleteResource");
    // print(params);
    try {
      final response = await apiService.request(
        endpoint: "/APP/AT/DeletePersonaXEncabezadoServicioAsync",
        method: "DELETE",
        data: params,
      );
      // print(response);
      return response;
    } on DioException catch (e) {
      log("Error en la API: ${e.response?.statusCode} - ${e.response?.data}");
      return {};
    } catch (e) {
      log("Error inesperado en deleteResource: $e");
      return {};
    }
  }

  // >> update rol resource
  Future<Object> updateRolResource(Map<String, dynamic> params) async {
    print(jsonEncode(params));
    print("updateRolResource");

    try {
      final response = await apiService.request(
        endpoint: "/APP/AT/UpdateRolJsonAsync",
        method: "PUT",
        data: jsonEncode(params),
      );
      return response;
    } on DioException catch (e) {
      log("Error en la API: ${e.response?.statusCode} - ${e.response?.data}");
      return {};
    } catch (e) {
      log("Error inesperado en updateRolResource: $e");
      return {};
    }
  }

  // validacion fechas - dayMore
  bool isNextDay(DateTime nowTime, DateTime stdTime) {
    final nowDateOnly = DateTime(nowTime.year, nowTime.month, nowTime.day);
    final stdDateOnly = DateTime(stdTime.year, stdTime.month, stdTime.day);

    return stdDateOnly.isAfter(nowDateOnly);
  }
}
