import 'package:dio/dio.dart';
import 'package:apptalma_v9/core/network/apis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

class ApiService {
  final Dio _dio;

  ApiService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: "", // Se establecerá dinámicamente
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 30),
          ),
        ) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 🔹 Establecer baseUrl según ambiente guardado
        final prefs = await SharedPreferences.getInstance();
        final env = prefs.getString('environment') ?? 'PROD';

        switch (env) {
          case 'QAS':
            options.baseUrl = APIs.cio5URLQAS;
            break;
          case 'DEV':
            options.baseUrl = APIs.cio5URLDEV;
            break;
          default:
            options.baseUrl = APIs.cio5URLProduction;
        }

        // 🔹 Agregar token si existe
        final token = await _getToken();
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }

        return handler.next(options);
      },
      onError: (DioException error, handler) {
        _handleError(error);
        return handler.next(error);
      },
    ));
  }

  Future<T> request<T>({
    required String endpoint,
    required String method,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Map<String, String>? customHeaders,
  }) async {
    try {
      final response = await _dio.request(
        endpoint,
        queryParameters: queryParameters,
        data: data,
        options: Options(
          method: method,
          headers: customHeaders,
        ),
      );

      return response.data as T;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response?.statusCode;
      final errorMessage = error.response?.data;
      if (statusCode == 401) {
        _logout();
        throw Exception("Unauthorized: $errorMessage");
      } else {
        throw Exception("Error $statusCode: $errorMessage");
      }
    } else {
      throw Exception("Network error: ${error.message}");
    }
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  void _logout() async {
    log("Session expired. Logging out...");
    await clearToken();
  }
}
