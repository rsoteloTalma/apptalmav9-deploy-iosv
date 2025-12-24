import 'package:flutter/material.dart';
import 'package:apptalma_v9/modules/general/panel/data/models/request/menu_item_response.dart';

class DrawerParamsProvider extends ChangeNotifier {
  List<MenuItemResponse> _subItems = [];
  String _userName = "";

  List<MenuItemResponse> get subItems => _subItems;
  String get userName => _userName;

  void setDrawerParams({
    required List<MenuItemResponse> subItems,
    required String userName,
  }) {
    _subItems = subItems;
    _userName = userName;
    notifyListeners();
  }

  void clearDrawerParams() {
    _subItems = [];
    _userName = "";
    notifyListeners();
  }
}
