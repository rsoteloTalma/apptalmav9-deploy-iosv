import 'package:dio/dio.dart';
import 'package:apptalma_v9/core/network/apis.dart';
import 'package:apptalma_v9/core/network/conectivity_service.dart';
import 'package:apptalma_v9/shared/constants/app_strings.dart';
import 'package:apptalma_v9/core/models/user.dart';
import 'package:apptalma_v9/core/models/generic_response.dart';
import 'package:apptalma_v9/modules/general/authentication/data/models/sign_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CIO5Datasource {
  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  /// Ajusta el baseUrl dinámicamente según el ambiente guardado en SharedPreferences
  Future<void> _setBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final env = prefs.getString('environment') ?? 'PROD';

    switch (env) {
      case 'QAS':
        dio.options.baseUrl = APIs.cio5URLQAS;
        break;
      case 'DEV':
        dio.options.baseUrl = APIs.cio5URLDEV;
        break;
      default:
        dio.options.baseUrl = APIs.cio5URLProduction;
    }
  }

  Future<GenericResponse<User>> getSignin(SignRequest request) async {
    try {
      // 1) Conectividad
      final connectivityService = ConnectivityService();
      if (!await connectivityService.checkConnection()) {
        return GenericResponse(success: 0, message: AppStrings.notConnection);
      }

      // 2) Base URL dinámico
      await _setBaseUrl();

      // 3) Petición
      final Response response = await dio.post(
        'Authenticator/Authenticate/',
        data: request.toJson(),
      );

      // 4) La API puede responder 200 con "success" pero sin "data"
      final body = response.data;

      // Garantizamos que sea un Map
      if (body is! Map) {
        return GenericResponse(success: 0, message: 'Respuesta inválida del servidor.');
      }

      final success = body['success'];              // puede ser int/string según tu API
      final message = body['message'] as String?;   // mensaje de negocio
      final data = body['data'];                    // payload (puede ser null)

      // Caso: 200 pero data viene null -> mostramos message del backend
      if (data == null) {
        return GenericResponse(
          success: 0, // o podrías devolver success tal cual, pero para flujo de app es error
          message: message ?? 'Sin datos.',
        );
      }

      // Caso OK con data
      final user = User.fromJson(data as Map<String, dynamic>);
      return GenericResponse(success: 1, message: '', data: user);
    } on DioException catch (e) {
      // La API suele enviar { message, errors, ... }
      final serverMsg = _extractServerMessage(e);
      return GenericResponse(success: 0, message: serverMsg);
    } catch (_) {
      return GenericResponse(success: 0, message: 'Ocurrió un error en la petición');
    }
  }

  String _extractServerMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }
      return e.message ?? 'Error desconocido';
    } catch (_) {
      return 'Error desconocido';
    }
  }
}
