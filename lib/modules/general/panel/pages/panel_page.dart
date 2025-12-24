import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

import 'package:apptalma_v9/core/models/session.dart';
import 'package:apptalma_v9/core/providers/user_provider.dart';
import 'package:apptalma_v9/core/providers/permissions_provider.dart';

import 'package:apptalma_v9/shared/utils/icon_mapper.dart';
import 'package:apptalma_v9/modules/general/panel/controller/panel_controller.dart';
import 'package:apptalma_v9/modules/general/panel/data/models/request/airport_info_request_model.dart';

class PanelPage extends StatefulWidget {
  final Session sessionData;

  const PanelPage({super.key, required this.sessionData});

  @override
  State<PanelPage> createState() => _PanelMainState();
}

class _PanelMainState extends State<PanelPage> {
  PanelController? controller;
  late Future<AirportInfo> _infoStation;

  bool _initialized = false;

  List<String> formatTitle(String text) {
    if (text.contains('-')) {
      return text.split('-');
    } else {
      return [text];
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user == null) {
        log("PanelPage: no hay usuario");
        return;
      }
      controller = PanelController(user);
      if (user.operationAirportId != null) {
        _infoStation = controller!.getStation(user.operationAirportId!);
      } else {
        log("operationAirportId es null");
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionsProvider = context.watch<PermissionsProvider>();
    final groupedPermissions = permissionsProvider.groupedByAbbreviation;

    return Scaffold(
      body: Column(
        children: [
          // ======= INFO DEL AEROPUERTO =======
          FutureBuilder<AirportInfo>(
            future: _infoStation,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData) {
                return const Center(child: Text("No hay datos disponibles"));
              }

              AirportInfo airportInfo = snapshot.data!;

              return Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.25,
                        width: double.infinity,
                        child: airportInfo.airportImage.startsWith('http')
                            ? Image.network(
                                airportInfo.airportImage,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.black12,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.broken_image,
                                      color: Colors.white70, size: 40),
                                ),
                              )
                            : Image.asset(
                                airportInfo.airportImage,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.black12,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.broken_image,
                                      color: Colors.white70, size: 40),
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: -20,
                        left: 15,
                        right: 15,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 10),
                              decoration: BoxDecoration(
                                color:
                                    Colors.black.withAlpha((255 * 0.4).toInt()),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    airportInfo.airportMessage,
                                    textAlign: TextAlign.justify,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.place,
                                          color: Colors.white, size: 15),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "${airportInfo.name}, ${airportInfo.code}",
                                          style: const TextStyle(
                                              color: Colors.white),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 30),

          // ======= LISTA DE PERMISOS AGRUPADOS =======
          Expanded(
            child: groupedPermissions.isEmpty
                ? const Center(child: Text("No hay permisos disponibles"))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: groupedPermissions.keys.length,
                    itemBuilder: (context, index) {
                      final abbreviation =
                          groupedPermissions.keys.elementAt(index);
                      final group = groupedPermissions[abbreviation]!;
                      final firstPermission = group.first;
                      final titles = formatTitle(abbreviation);

                      return InkWell(
                        onTap: () {
                          final user =
                              Provider.of<UserProvider>(context, listen: false)
                                  .user;
                          final route = firstPermission.url ?? '/';

                          context.push(
                            route,
                            extra: {
                              'subItems': firstPermission.subItems
                                  .map((e) => e.toJson())
                                  .toList(),
                              'userName': user?.name ?? "Usuario",
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: const BorderDirectional(
                                top: BorderSide(color: Colors.black12)),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade400
                                    .withAlpha((255 * 0.5).toInt()),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 10, 20, 10),
                                child: CircleAvatar(
                                  backgroundColor: Colors.lightBlue.shade200,
                                  child: Icon(
                                    getIconFromString(
                                        firstPermission.permissionIcon),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      titles.first,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineLarge,
                                    ),
                                    Text(
                                      (titles.length > 1)
                                          ? titles[1]
                                          : titles.first,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
