import 'dart:async';
import 'package:apptalma_v9/core/models/session.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:apptalma_v9/modules/general/panel/data/models/request/menu_item_response.dart';
import 'package:apptalma_v9/core/providers/user_provider.dart';
import 'package:apptalma_v9/shared/utils/icon_mapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubMenuDrawer extends StatefulWidget {
  final List<MenuItemResponse> subItems;
  final void Function(MenuItemResponse) onItemTap;
  final String userName;

  const SubMenuDrawer({
    super.key,
    required this.subItems,
    required this.onItemTap,
    required this.userName,
  });

  @override
  State<SubMenuDrawer> createState() => _SubMenuDrawerState();
}

class _SubMenuDrawerState extends State<SubMenuDrawer> {
  late StreamSubscription<ConnectivityResult> _subscription;
  ConnectivityResult _connectivityStatus = ConnectivityResult.none;
  int _selectedIndex = -1;
  String _appVersion = '';
  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _connectivityStatus = result;
      });
    });

    Connectivity().checkConnectivity().then((result) {
      setState(() {
        _connectivityStatus = result;
      });
    });
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = 'v${info.version}';
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  String get connectivityLabel {
    switch (_connectivityStatus) {
      case ConnectivityResult.wifi:
        return "WiFi";
      case ConnectivityResult.mobile:
        return "Datos";
      case ConnectivityResult.none:
        return "Sin conexión";
      default:
        return "Desconocido";
    }
  }

  IconData get connectivityIcon {
    switch (_connectivityStatus) {
      case ConnectivityResult.wifi:
        return Icons.wifi;
      case ConnectivityResult.mobile:
        return Icons.signal_cellular_alt;
      case ConnectivityResult.none:
        return Icons.signal_wifi_off;
      default:
        return Icons.help_outline;
    }
  }

  Color get statusColor {
    return _connectivityStatus == ConnectivityResult.none
        ? Colors.red
        : Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF002C6B),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Center(
                child: Image.asset(
                  'assets/images/talma_white.png',
                  height: 50,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Hola, ${widget.userName.toUpperCase()}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(connectivityIcon, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    connectivityLabel.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.subItems.length,
                  itemBuilder: (context, index) {
                    final item = widget.subItems[index];
                    final bool isSelected = index == _selectedIndex;

                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });

                            final route = item.url;

                            Navigator.of(context).pop();
                            context.go(
                              route.startsWith('/') ? route : '/$route',
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  getIconFromString(item.icon),
                                  color: isSelected
                                      ? const Color(0xFF002C6B)
                                      : Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  item.text,
                                  style: TextStyle(
                                    color: isSelected
                                        ? const Color(0xFF002C6B)
                                        : Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(
                          color: Colors.white24,
                          thickness: 0.5,
                          indent: 10,
                          endIndent: 10,
                          height: 12,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Divider(color: Colors.white24),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Recuperamos la sesión guardada del UserProvider
                    final userProvider =
                        Provider.of<UserProvider>(context, listen: false);
                    final user = userProvider.user;

                    if (user == null) {
                      // Si no hay usuario, mandamos al login
                      context.go('/');
                      return;
                    }

                    // Construimos la sesión actual
                    final sessionData = Session(
                      user: user,
                      enviroment:
                          'production', // Aquí usa el valor real según tu flujo
                      appVersion:
                          '1.0.0', // Aquí usa el valor real desde config
                    );

                    // Navegamos al panel con la sesión completa
                    context.go('/panel', extra: sessionData);
                  },
                  child: const Text(
                    "INICIO",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const Divider(color: Colors.white24),
              Center(
                child: TextButton(
                  onPressed: () async {
                    final userProvider =
                        Provider.of<UserProvider>(context, listen: false);
                    userProvider.clearUser();

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove("token");
                    await prefs.remove("session");

                    context.go('/');
                  },
                  child: const Text(
                    "CERRAR SESIÓN",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const Divider(color: Colors.white24),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  _appVersion.isNotEmpty ? _appVersion : "v...",
                  style: TextStyle(color: Colors.white.withOpacity(0.6)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
