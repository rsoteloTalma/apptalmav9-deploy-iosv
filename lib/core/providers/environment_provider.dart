import 'package:apptalma_v9/core/network/apis.dart';
import 'package:flutter/material.dart';

class EnvironmentProvider extends ChangeNotifier {
  String _baseUrl = APIs.cio5URLProduction;

  String get baseUrl => _baseUrl;

  void setEnvironment(String environment) {
    switch (environment) {
      case 'QAS':
        _baseUrl = APIs.cio5URLQAS;
        break;
      case 'DEV':
        _baseUrl = APIs.cio5URLDEV;
        break;
      default:
        _baseUrl = APIs.cio5URLProduction;
    }
    notifyListeners();
  }
}
