import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:apptalma_v9/core/models/session.dart';
import 'package:apptalma_v9/core/providers/drawer_params_provider.dart';

// main pages
import 'package:apptalma_v9/modules/at/assigned-services/pages/detail_services_page.dart';
import 'package:apptalma_v9/modules/general/panel/data/models/request/menu_item_response.dart';
import 'package:apptalma_v9/modules/general/authentication/authentication_main_page.dart';
import 'package:apptalma_v9/modules/general/panel/panel_main.dart';
import 'package:apptalma_v9/modules/general/flight-info/flight_info_main.dart';
import 'package:apptalma_v9/modules/general/profile/profile_main.dart';
import 'package:apptalma_v9/modules/at/panel/pages/at_page.dart';
import 'package:apptalma_v9/modules/at/assigned-services/pages/assigned_service_page.dart';
import 'package:apptalma_v9/modules/at/assigned-services/data/models/ground_services_model.dart';

class Routes {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // 🔹 Login
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthenticationMainPage(),
      ),

      // 🔹 Panel principal
      GoRoute(
        path: '/panel',
        builder: (context, state) {
          final sessionData = state.extra as Session;
          return PanelMain(sessionData: sessionData);
        },
      ),

      // 🔹 Info de vuelos
      GoRoute(
        path: '/flight-info',
        builder: (context, state) => FlightInfoMain(),
      ),

      // 🔹 Perfil
      GoRoute(
        path: '/profile',
        builder: (context, state) {
          final sessionData = state.extra as Session;
          return ProfileMain(sessionData: sessionData);
        },
      ),

      // 🔹 Página principal AT
      GoRoute(
        path: '/home-at',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;

          // Obtenemos los datos que vienen de panel
          final subItems = (extra['subItems'] as List)
              .map((e) => MenuItemResponse.fromJson(e as Map<String, dynamic>))
              .toList();
          final userName = extra['userName'] as String;

          // Actualizamos el provider con los parámetros del drawer
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<DrawerParamsProvider>().setDrawerParams(
                  subItems: subItems,
                  userName: userName,
                );
          });

          // Página sin props, todo se obtiene del provider
          return const AtHomePage();
        },
      ),

      // 🔹 Servicios asignados
      GoRoute(
        path: '/assigned-services',
        builder: (context, state) => const AssignedServicesPage(),
      ),

      // 🔹 Detalle del servicio
      GoRoute(
        path: '/detail-service',
        builder: (context, state) {
          final service = state.extra as GroundServices;
          return DetailServicesPage(service: service);
        },
      ),
    ],
    errorBuilder: (context, state) => const Scaffold(
      body: Center(child: Text('Página no encontrada')),
    ),
  );
}
