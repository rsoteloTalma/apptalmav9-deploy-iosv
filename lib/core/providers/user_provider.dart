import 'package:flutter/material.dart';
import 'package:apptalma_v9/core/models/user.dart';

class UserProvider extends ChangeNotifier {
  User? _user;

  /// Getter público para acceder al usuario
  User? get user => _user;

  /// Setter explícito con notifyListeners para actualizar la UI
  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  /// Método para limpiar el usuario actual (logout o expiración)
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
