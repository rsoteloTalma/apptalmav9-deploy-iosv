import 'package:flutter/material.dart';
import 'package:apptalma_v9/modules/general/config/data/models/app_config_model.dart';

class ConfigProvider extends ChangeNotifier {
  List<AppConfig> _configs = [];

  List<AppConfig> get configs => _configs;

  void setConfigs(List<AppConfig> configs) {
    _configs = configs;
    notifyListeners();
  }
}
