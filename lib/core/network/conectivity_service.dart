import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  late Stream<ConnectivityResult> _connectivityStream;

  ConnectivityService() {
    _connectivityStream = _connectivity.onConnectivityChanged;
  }

  Stream<ConnectivityResult> get connectivityStream => _connectivityStream;

  Future<IconData> checkConnectionType() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    return getConnectionType(connectivityResult);
  }

  Future<bool> checkConnection() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  IconData getConnectionType(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return Icons.wifi;
      case ConnectivityResult.mobile:
        return Icons.network_cell;
      case ConnectivityResult.ethernet:
        return Icons.cable;
      case ConnectivityResult.bluetooth:
        return Icons.bluetooth;
      case ConnectivityResult.none:
        return Icons.signal_wifi_bad;
      default:
        return Icons.device_unknown;
    }
  }
}
