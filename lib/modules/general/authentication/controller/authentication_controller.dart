import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:apptalma_v9/core/models/generic_response.dart';
import 'package:apptalma_v9/core/models/user.dart';
import 'package:apptalma_v9/core/network/conectivity_service.dart';
import 'package:apptalma_v9/modules/general/authentication/data/datasources/cio5_datasource.dart';
import 'package:apptalma_v9/modules/general/authentication/data/models/sign_request.dart';
import 'package:apptalma_v9/shared/constants/app_strings.dart';
import 'package:apptalma_v9/core/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationController {
  final CIO5Datasource _myAuth = CIO5Datasource();
  final ConnectivityService _connectivityService = ConnectivityService();

  Future<GenericResponse<User>> getSignin(
      BuildContext context, SignRequest request) async {
    if (await _connectivityService.checkConnection()) {
      GenericResponse<User> response = await _myAuth.getSignin(request);

      if (response.success == 1 && response.data != null) {
        Provider.of<UserProvider>(context, listen: false)
            .setUser(response.data!);

        // 🔐 GUARDAR TOKEN EN MEMORIA PERSISTENTE
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', response.data!.token);
      }

      return response;
    } else {
      return GenericResponse(success: 3, message: AppStrings.notConnection);
    }
  }
}
