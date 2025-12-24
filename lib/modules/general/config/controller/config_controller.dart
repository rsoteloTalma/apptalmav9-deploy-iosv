import 'package:apptalma_v9/core/network/network.dart';
import 'package:apptalma_v9/modules/general/config/data/models/app_config_model.dart';

class ConfigController {
  final ApiService apiService = ApiService();

  Future<List<AppConfig>> getAppConfig(String module) async {
    final response = await apiService.request<List<dynamic>>(
      endpoint: "General/GetAPPConfig",
      method: "GET",
      queryParameters: {
        "module": module,
      },
    );

    return response.map((e) => AppConfig.fromJson(e)).toList();
  }
}
