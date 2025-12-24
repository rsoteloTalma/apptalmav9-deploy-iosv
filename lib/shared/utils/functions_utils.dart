import 'package:apptalma_v9/modules/general/config/data/models/app_config_model.dart';

String getValueByKey(List<AppConfig> configs, String searchKey) {
  final config = configs.firstWhere(
    (element) => element.key == searchKey,
    orElse: () => AppConfig(appConfigId: 0, key: "", value: "", module: ""),
  );

  return config.key.isNotEmpty ? config.value : "-";
}
