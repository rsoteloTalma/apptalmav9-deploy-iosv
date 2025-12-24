import 'dart:convert';
import 'package:apptalma_v9/core/providers/permissions_provider.dart';
import 'package:apptalma_v9/modules/general/panel/controller/panel_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:apptalma_v9/core/models/generic_response.dart';
import 'package:apptalma_v9/core/models/session.dart';
import 'package:apptalma_v9/core/models/user.dart';
import 'package:apptalma_v9/modules/general/authentication/controller/authentication_controller.dart';
import 'package:apptalma_v9/modules/general/authentication/data/models/sign_request.dart';
import 'package:apptalma_v9/core/theme/app_colors.dart';
import 'package:apptalma_v9/shared/constants/app_strings.dart';
import 'package:apptalma_v9/shared/widgets/app_snackbar_widget.dart';
import 'package:apptalma_v9/core/providers/environment_provider.dart';
import 'package:apptalma_v9/core/providers/config_provider.dart';
import 'package:apptalma_v9/modules/general/config/controller/config_controller.dart';
import 'package:apptalma_v9/modules/general/config/data/models/app_config_model.dart';

class AppStrings {
  static const String productionEnvironment = 'PROD';
  static const String qasEnvironment = 'QAS';
  static const String devEnvironment = 'DEV';
}

class AuthenticationMainPage extends StatefulWidget {
  const AuthenticationMainPage({super.key});

  @override
  _AuthenticationMainPageState createState() => _AuthenticationMainPageState();
}

class _AuthenticationMainPageState extends State<AuthenticationMainPage> {
  String selectedEnvironment = AppStrings.productionEnvironment; // 🔹 Producción por defecto
  bool isLoading = false;
  bool isCheckingToken = false;
  String userName = "";
  String password = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _appVersion = 'Versión desconocida';
  final AuthenticationController authenticationController =
      AuthenticationController();

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _loadSavedEnvironment();
  }

  Future<void> _loadAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  Future<void> _loadSavedEnvironment() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEnv = prefs.getString('environment');

    if (savedEnv != null && savedEnv.isNotEmpty) {
      setState(() {
        selectedEnvironment = savedEnv;
      });
    } else {
      setState(() {
        selectedEnvironment = AppStrings.productionEnvironment; // 🔹 Valor por defecto
      });
    }
  }

  Future<void> _saveEnvironment(String envKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('environment', envKey);
  }

  void _selectEnvironment(String envKey) async {
    setState(() {
      selectedEnvironment = envKey;
    });

    await _saveEnvironment(envKey);
    context.read<EnvironmentProvider>().setEnvironment(envKey);
    Navigator.pop(context);
  }

  void showEnvironmentSelector() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: const Text('Producción'),
              leading: Radio<String>(
                value: AppStrings.productionEnvironment,
                groupValue: selectedEnvironment,
                onChanged: (value) => _selectEnvironment(AppStrings.productionEnvironment),
              ),
              onTap: () => _selectEnvironment(AppStrings.productionEnvironment),
            ),
            ListTile(
              title: const Text('QAS'),
              leading: Radio<String>(
                value: AppStrings.qasEnvironment,
                groupValue: selectedEnvironment,
                onChanged: (value) => _selectEnvironment(AppStrings.qasEnvironment),
              ),
              onTap: () => _selectEnvironment(AppStrings.qasEnvironment),
            ),
            ListTile(
              title: const Text('DEV'),
              leading: Radio<String>(
                value: AppStrings.devEnvironment,
                groupValue: selectedEnvironment,
                onChanged: (value) => _selectEnvironment(AppStrings.devEnvironment),
              ),
              onTap: () => _selectEnvironment(AppStrings.devEnvironment),
            ),
          ],
        );
      },
    );
  }

  Color getEnvironmentIconColor() {
    switch (selectedEnvironment) {
      case AppStrings.productionEnvironment:
        return Colors.grey;
      case AppStrings.qasEnvironment:
      case AppStrings.devEnvironment:
        return AppColors.testColor;
      default:
        return Colors.grey;
    }
  }

  void handleLogin(BuildContext context) async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
    }

    if (_formKey.currentState!.validate()) {
      SignRequest signRequest =
          SignRequest(user: userName, password: password, appId: 4);

      GenericResponse<User> response =
          await authenticationController.getSignin(context, signRequest);

      if (response.success == 1) {
        Session session = Session(
          user: response.data!,
          enviroment: selectedEnvironment,
          appVersion: _appVersion,
        );

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', session.user.token);
        await prefs.setString('session', jsonEncode(session.toJson()));
        await prefs.setString('environment', selectedEnvironment);

        try {
          final configController = ConfigController();
          final configs = await configController.getAppConfig("General");
          context.read<ConfigProvider>().setConfigs(configs);

          // Verificación de versión
          String versionRequired = configs
              .firstWhere(
                (c) => c.key == "Version_Required",
                orElse: () =>
                    AppConfig(appConfigId: 0, key: "", value: "", module: ""),
              )
              .value;

          bool versionUpdate = configs
                  .firstWhere(
                    (c) => c.key == "Version_Update",
                    orElse: () => AppConfig(
                        appConfigId: 0, key: "", value: "false", module: ""),
                  )
                  .value
                  .toLowerCase() ==
              "true";

          String updateUrl = configs
              .firstWhere(
                (c) => c.key == "Update_URL",
                orElse: () =>
                    AppConfig(appConfigId: 0, key: "", value: "", module: ""),
              )
              .value;

          if (versionUpdate && _isLowerVersion(_appVersion, versionRequired)) {
            _showUpdateDialog(context, versionRequired, updateUrl);
            setState(() => isLoading = false);
            return;
          }
        } catch (e) {
          debugPrint("Error al cargar configuración: $e");
        }

        // 🔹 Cargar permisos al provider
        try {
          final panelController = PanelController(session.user);
          final permissions = await panelController.getPermissions(1);
          context.read<PermissionsProvider>().setPermissions(permissions);
        } catch (e) {
          debugPrint("Error al cargar permisos: $e");
        }

        context.go('/panel', extra: session);
      } else {
        AppSnackbarWidget.show(
          context,
          response.message!,
          Icons.warning_rounded,
          AppColors.orangeAlert,
        );
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  bool _isLowerVersion(String current, String required) {
    List<int> currentParts = current
        .replaceAll(RegExp(r'[^0-9.]'), '')
        .split('.')
        .map(int.parse)
        .toList();
    List<int> requiredParts = required
        .replaceAll(RegExp(r'[^0-9.]'), '')
        .split('.')
        .map(int.parse)
        .toList();

    for (int i = 0; i < requiredParts.length; i++) {
      if (i >= currentParts.length || currentParts[i] < requiredParts[i]) {
        return true;
      } else if (currentParts[i] > requiredParts[i]) {
        return false;
      }
    }
    return false;
  }

  void _showUpdateDialog(
      BuildContext context, String versionRequired, String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Actualización requerida"),
        content: Text(
            "Debes actualizar la aplicación a la versión $versionRequired para continuar."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (url.isNotEmpty) {
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              }
            },
            child: const Text("Actualizar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTablet = screenWidth >= 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isCheckingToken
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
                strokeWidth: 2.0,
              ),
            )
          : Form(
              key: _formKey,
              child: Center(
                child: FractionallySizedBox(
                widthFactor: isTablet ? 0.5 : 0.9,
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  onPressed: showEnvironmentSelector,
                                  icon: const Icon(Icons.settings),
                                  color: getEnvironmentIconColor(),
                                  iconSize: 24,
                                  tooltip: 'Seleccionar entorno',
                                ),
                              ],
                            ),
                            Center(
                              child: Image.asset(
                                'assets/images/logo_talma.png',
                                height: 100,
                              ),
                            ),
                            const SizedBox(height: 40),
                            TextFormField(
                              enabled: !isLoading,
                              decoration: const InputDecoration(
                                labelText: 'Usuario',
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: AppColors.textGrey,
                                ),
                              ),
                              onChanged: (value) => userName = value,
                              validator: (value) => value!.isEmpty
                                  ? "Este campo es obligatorio"
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              enabled: !isLoading,
                              decoration: const InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: AppColors.textGrey,
                                ),
                              ),
                              obscureText: true,
                              onChanged: (value) => password = value,
                              validator: (value) => value!.isEmpty
                                  ? "Este campo es obligatorio"
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed:
                                  isLoading ? null : () => handleLogin(context),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                backgroundColor: selectedEnvironment ==
                                        AppStrings.productionEnvironment
                                    ? AppColors.primaryColor
                                    : AppColors.testColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.0,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.login),
                                        SizedBox(width: 8),
                                        Text(
                                          'Iniciar sesión',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    ),
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Versión $_appVersion",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                ),
              ),
            ),
    );
  }
}
