import 'package:apptalma_v9/core/providers/config_provider.dart';
import 'package:apptalma_v9/core/providers/drawer_params_provider.dart';
import 'package:apptalma_v9/core/providers/environment_provider.dart';
import 'package:apptalma_v9/core/providers/permissions_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/routes.dart';
import 'core/theme/talma_theme.dart';
import 'core/providers/user_provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => EnvironmentProvider()),
        ChangeNotifierProvider(create: (_) => ConfigProvider()),
        ChangeNotifierProvider(create: (_) => PermissionsProvider()),
        ChangeNotifierProvider(create: (_) => DrawerParamsProvider()),
      ],
      child: MaterialApp.router(
        title: 'Talma App',
        theme: TalmaTheme.defaultTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: Routes.router,
      ),
    );
  }
}
