import 'dart:convert';

import 'package:apptalma_v9/shared/utils/functions_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:apptalma_v9/core/theme/app_colors.dart';
import 'package:apptalma_v9/core/theme/talma_custom_theme.dart';
import 'package:apptalma_v9/shared/qr/qr_scanner_page.dart';

import 'package:apptalma_v9/core/providers/user_provider.dart';
import 'package:apptalma_v9/shared/widgets/app_snackbar_widget.dart';
import 'package:apptalma_v9/shared/widgets/confirm_dialog_widget.dart';

import 'package:apptalma_v9/modules/general/config/controller/config_controller.dart';
import 'package:apptalma_v9/modules/general/config/data/models/app_config_model.dart';
import 'package:apptalma_v9/modules/at/assigned-services/controller/assigned_services_controller.dart';
import 'package:apptalma_v9/modules/at/assigned-services/data/models/type_roles_model.dart';
import 'package:apptalma_v9/modules/at/assigned-services/data/models/ground_services_model.dart';
import 'package:apptalma_v9/modules/at/assigned-services/data/models/resource_by_service_model.dart';
import 'package:apptalma_v9/modules/at/assigned-services/data/models/add_resource_model.dart';
import 'package:apptalma_v9/modules/at/assigned-services/data/models/flight_roles_model.dart';

class DetailServicesPage extends StatefulWidget {
  final GroundServices service;
  const DetailServicesPage({super.key, required this.service});

  @override
  State<DetailServicesPage> createState() => _DetailServicesPageState();
}

class _DetailServicesPageState extends State<DetailServicesPage> {
  final GroundServicesController _controller = GroundServicesController();
  final configController = ConfigController();

  List<ResourceByService> _resources = [];
  List<TypeRoles> _roles = [];
  List<AppConfig> _config = [];
  bool _isLoading = true;
  String qrValue = "";

  void _updateLocalRoleInParent({
    required int personId,
    required String roleName,
    required bool value,
  }) {
    setState(() {
      final i = _resources.indexWhere((r) => r.personId == personId);
      if (i == -1) return;
      final j = _resources[i].roles.indexWhere((rr) => rr.roleName == roleName);
      if (j == -1) return;

      _resources[i].roles[j] = _resources[i].roles[j].copyWith(isCheck: value);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadResorces();
    _loadRoles();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final cnf = await configController.getAppConfig("AT");
      setState(() {
        _config = cnf;
      });
    } catch (e) {
      setState(() {
        _config = [];
      });
    }
  }

  Future<void> _loadResorces() async {
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;

      var myResources = await _controller
          .getResourceByService(widget.service.serviceHeaderId);

      if (myResources.isEmpty) {
        ProcessResult success = await _runAssignment(user!.employeeId);

        if (success.state == true) {
          myResources = await _controller
              .getResourceByService(widget.service.serviceHeaderId);
        }
      }

      setState(() {
        _resources = myResources;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _resources = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRoles() async {
    try {
      final roles = await _controller.getFlightRoles();
      setState(() {
        _roles = roles;
      });
    } catch (e) {
      setState(() {
        _roles = [];
      });
    }
  }

  Future<ProcessResult> _runAssignment(String employeeId,
      {bool total = true}) async {
    bool next = true;
    int returnValueId = 0;

    setState(() {
      _isLoading = true;
    });

    final getInfo = {
      "serviceHeaderId": widget.service.serviceHeaderId,
      "identification": employeeId,
      "userId": widget.service.personId,
      "stageTypeId": widget.service.serviceTypeStageId,
      "processName": "RAMPA"
    };

    final getSimultaneity = {
      "serviceHeaderId": widget.service.serviceHeaderId,
      "resourceType": true,
      "stageTypeId": widget.service.serviceTypeStageId,
      "identification": employeeId
    };

    final autoInfoResources = await _controller.infoResources(getInfo);

    if (!autoInfoResources.statusCoverageProcessAlert && total) {
      String disclaimerMessage =
          getValueByKey(_config, "AssigmentDisclaimerMessage");

      final resultStatusCoverage = await showConfirmationDialog(
        context,
        title: "Alerta Habilitación",
        message: disclaimerMessage,
      );

      if (resultStatusCoverage == false) {
        next = false;
        return ProcessResult(
          state: false,
          message: disclaimerMessage,
        );
      }
    }

    if (next) {
      final autoValidateSimultaneity =
          await _controller.validateSimultaneity(getSimultaneity);

      if (autoValidateSimultaneity.simultaneity && total) {
        final resultSimultaneity = await showConfirmationDialog(
          context,
          title: "Simultaneidad",
          message: autoValidateSimultaneity.validationErrorMessage,
        );

        if (resultSimultaneity == false) {
          next = false;
          return ProcessResult(
            state: false,
            message: "Usuario canceló en simultaneidad",
          );
        } else {
          returnValueId = autoValidateSimultaneity.returnValueId;
          next = true;
        }
      }
    }

    if (next) {
      List<FlightRoles> roles = autoInfoResources.roles;

      AddResource setAddResource = AddResource(
        userId: widget.service.personId,
        serviceHeaderId: widget.service.serviceHeaderId,
        employeeId: employeeId,
        processStatus: autoInfoResources.statusCoverageProcess,
        processName: "RAMPA",
        valueDataId: returnValueId,
        stageTypeId: widget.service.serviceTypeStageId,
        roles: roles,
      );

      await _controller.addResource(setAddResource);
    }

    return ProcessResult(
      state: true,
      message: "Proceso completado con éxito",
    );
  }

  void _openScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QrScannerPage(
          taskId: 1,
          directCapture: false,
          onSave: (value) async {
            if (!mounted) return;
            setState(() {
              qrValue = value;
            });

            final success = await _runAssignment(value);
            if (success.state == true) {
              await _loadResorces();
            }
          },
        ),
      ),
    );

    if (result != null) {
      if (!mounted) return;
      setState(() {
        qrValue = result;
      });
    }
  }

  Future<void> _showRoleBottomSheet(dynamic data, String type) {
    final parentContext = context;

    return showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final List<FlightRoles> localRoles = List<FlightRoles>.from(
          type == "T"
              ? (data.roles as List<FlightRoles>)
              : const <FlightRoles>[],
        );
        final Set<int> updating = <int>{};

        return StatefulBuilder(
          builder: (context, setStateSB) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              minChildSize: 0.0,
              maxChildSize: 0.95,
              builder: (_, controller) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    controller: controller,
                    children: [
                      Center(
                        child: Container(
                          height: 4,
                          width: 40,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.person, size: 36),
                        title:
                            Text((type == "T") ? data.employeeName : data.name),
                        subtitle: Text((type == "T") ? data.position : "RAMPA"),
                        trailing: (type == "T")
                            ? (data.statusCoverageProcess == "CUMPLE"
                                ? const Icon(Icons.check,
                                    size: 36, color: AppColors.greenAlert)
                                : const Icon(Icons.block,
                                    size: 36, color: Colors.red))
                            : const Text("-"),
                      ),
                      if (type == "T")
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: localRoles.length,
                          itemBuilder: (context, index) {
                            final role = localRoles[index];

                            return Container(
                              decoration: BoxDecoration(
                                color: role.statusCoverageRoleAlert
                                    ? Colors.blue.shade50
                                    : Colors.white,
                                border: Border.all(
                                    color: Colors.grey.shade400, width: 1),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 3),
                              child: ListTile(
                                title: Text(role.roleName),
                                trailing: Switch(
                                  value: role.isCheck,
                                  onChanged: updating.contains(index)
                                      ? null
                                      : (value) async {
                                          final sbCtx = context;

                                          // 1) Optimista: actualiza sheet
                                          setStateSB(() {
                                            updating.add(index);
                                            localRoles[index] =
                                                role.copyWith(isCheck: value);
                                          });

                                          // 1b) Optimista: actualiza la lista del padre al instante
                                          if (mounted) {
                                            _updateLocalRoleInParent(
                                              personId: data.personId,
                                              roleName: role.roleName,
                                              value: value,
                                            );
                                          }

                                          try {
                                            // 2) Llama API
                                            await _controller
                                                .updateRolResource({
                                              "encabezadoServicioId": widget
                                                  .service.serviceHeaderId,
                                              "personaId": data.personId,
                                              "rolJson": jsonEncode(localRoles
                                                  .map((r) => r.toJson())
                                                  .toList()),
                                              "usuarioModificador":
                                                  Provider.of<UserProvider>(
                                                          this.context,
                                                          listen: false)
                                                      .user
                                                      ?.employeeId,
                                            });

                                            // 3) Sync opcional desde servidor, sin romper la UI del sheet
                                            if (mounted) {
                                              // no bloquea el UI; refresco “en background”
                                              // ignore: discarded_futures
                                              _loadResorces();
                                            }
                                          } catch (e) {
                                            // Revertir en sheet si sigue montado
                                            if (sbCtx.mounted) {
                                              setStateSB(() {
                                                localRoles[index] = role
                                                    .copyWith(isCheck: !value);
                                              });
                                            }

                                            // 4b) Revertir en el padre si sigue montado
                                            if (mounted) {
                                              _updateLocalRoleInParent(
                                                personId: data.personId,
                                                roleName: role.roleName,
                                                value: !value,
                                              );
                                            }
                                          } finally {
                                            if (sbCtx.mounted) {
                                              setStateSB(() {
                                                updating.remove(index);
                                              });
                                            }
                                          }
                                        },
                                ),
                              ),
                            );
                          },
                        ),

                      // eliminar
                      const SizedBox(height: 10),
                      (type == "T")
                          ? ElevatedButton.icon(
                              onPressed: () async {
                                final confirmed = await showConfirmationDialog(
                                  context,
                                  title: "Eliminar",
                                  message:
                                      "¿Seguro que deseas eliminar este recurso?",
                                );
                                if (confirmed == false) return;

                                try {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  await _controller.deleteResource({
                                    "encabezadoServicioId":
                                        widget.service.serviceHeaderId,
                                    "personaId": data.personId,
                                    "rolJson": "[]",
                                    "usuarioModificador":
                                        Provider.of<UserProvider>(context,
                                                listen: false)
                                            .user
                                            ?.employeeId,
                                  });

                                  if (!mounted) return;

                                  Navigator.pop(parentContext);
                                  await _loadResorces();

                                  if (mounted) {
                                    ScaffoldMessenger.of(parentContext)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Recurso eliminado.",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        duration: Duration(seconds: 2),
                                        backgroundColor: Colors.lightGreen,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  debugPrint("error >> $e");
                                  if (mounted) {
                                    ScaffoldMessenger.of(parentContext)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Error al eliminar.",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        duration: Duration(seconds: 2),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }
                              },
                              icon: const Icon(Icons.person_off,
                                  color: Colors.red),
                              label: const Text("Eliminar"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  side: const BorderSide(
                                      color: Colors.red, width: 2),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime nowDate = DateTime.now();
    final staTime = DateTime.parse(widget.service.vta);
    final stdTime = DateTime.parse(widget.service.vtd);

    bool arrived = widget.service.ata.trim().isNotEmpty;
    bool dayMore = _controller.isNextDay(nowDate, stdTime);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          title: const Text("Info Vuelo"),
          actions: const [
            Icon(Icons.more_vert),
            SizedBox(width: 12),
          ],
        ),
        body: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.talmaCyan],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.5, 0.5],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide.none,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    'https://content.airhex.com/content/logos/airlines_${widget.service.company}_110_40_r.png',
                                    width: 110,
                                    height: 30,
                                    fit: BoxFit.fill,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.broken_image,
                                          size: 30);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.service.incomingFlight,
                                      style: arrived
                                          ? Theme.of(context)
                                              .textTheme
                                              .disabledTitleLg
                                          : Theme.of(context)
                                              .textTheme
                                              .atFlightNumber,
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        widget.service.gate,
                                        style: Theme.of(context)
                                            .textTheme
                                            .atParking,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.service.origin,
                                      style: arrived
                                          ? Theme.of(context)
                                              .textTheme
                                              .disabledTitleMd
                                          : Theme.of(context)
                                              .textTheme
                                              .atFlightIata,
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        (staTime != null)
                                            ? DateFormat.Hm().format(staTime)
                                            : (widget.service.sta),
                                        style: arrived
                                            ? Theme.of(context)
                                                .textTheme
                                                .disabledTitleMd
                                            : Theme.of(context)
                                                .textTheme
                                                .atFlightTime,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 80,
                          color: Colors.grey,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.service.aircraft,
                                style:
                                    Theme.of(context).textTheme.atFlightNumber,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.service.outgoingFlight,
                                      style: Theme.of(context)
                                          .textTheme
                                          .atFlightNumber,
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        widget.service.gate,
                                        style: Theme.of(context)
                                            .textTheme
                                            .atParking,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.service.destiny,
                                      style: Theme.of(context)
                                          .textTheme
                                          .atFlightIata,
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: RichText(
                                        text: TextSpan(
                                          style: Theme.of(context)
                                              .textTheme
                                              .atFlightTime,
                                          children: [
                                            TextSpan(
                                              text: (stdTime != null)
                                                  ? DateFormat.Hm()
                                                      .format(stdTime)
                                                  : (widget.service.std),
                                            ),
                                            if (dayMore)
                                              const TextSpan(
                                                text: ' +1',
                                                style: TextStyle(
                                                  color: Colors.blueAccent,
                                                  fontSize: 14,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Tabs
            Container(
              color: AppColors.talmaCyan,
              child: const TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.primaryColor,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_alt_outlined),
                        SizedBox(width: 10),
                        Text('EQUIPO'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.checklist_rtl),
                        SizedBox(width: 10),
                        Text('ROLES'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      children: [
                        _TeamPage(
                          resources: _resources,
                          onAddTap: _openScanner,
                          onItemTap: (res) => _showRoleBottomSheet(res, "T"),
                        ),
                        _RolesPage(
                          roles: _roles,
                          resources: _resources,
                          onAddTap: _openScanner,
                          onItemTap: (role) => _showRoleBottomSheet(role, "R"),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamPage extends StatelessWidget {
  final List<ResourceByService> resources;
  final VoidCallback onAddTap;
  final void Function(ResourceByService) onItemTap;

  const _TeamPage({
    required this.resources,
    required this.onAddTap,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (resources.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppSnackbarWidget.show(
          context,
          "No hay recursos asignados",
          Icons.warning_rounded,
          AppColors.orangeAlert,
        );
      });
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: resources.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.primaryColor, width: 5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              onTap: onAddTap,
              child: const SizedBox(
                height: 70,
                child: Center(
                  child: Icon(
                    Icons.add,
                    color: AppColors.primaryColor,
                    size: 36,
                  ),
                ),
              ),
            ),
          );
        }

        final resource = resources[index - 1];

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                resource.employeeName.trim().isNotEmpty
                    ? resource.employeeName.trim().substring(0, 1)
                    : '-',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(resource.employeeName),
            subtitle: Text(resource.position),
            onTap: () => onItemTap(resource),
          ),
        );
      },
    );
  }
}

class _RolesPage extends StatelessWidget {
  final List<TypeRoles> roles;
  final List<ResourceByService> resources;
  final VoidCallback onAddTap;
  final void Function(TypeRoles) onItemTap;

  const _RolesPage({
    required this.roles,
    required this.resources,
    required this.onAddTap,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (roles.isEmpty) {
      return const Center(
        child: Text("No hay roles disponibles"),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: roles.length,
      itemBuilder: (context, index) {
        final role = roles[index];

        final matchingResource = resources.firstWhere(
          (res) => res.roles.any((r) => r.roleName == role.name),
          orElse: () => ResourceByService(
            serviceHeaderId: 0,
            personId: 0,
            employeeId: "",
            employeeName: "",
            companyIATACode: "",
            position: "",
            readingDate: "",
            readingEndDate: "",
            statusCoverageProcess: "",
            roles: [],
          ),
        );

        final hasMatch = matchingResource.employeeName.isNotEmpty;
        final subtitleText = hasMatch ? matchingResource.employeeName : "S/A";

        return Card(
          color: hasMatch ? Colors.green[100] : Colors.white,
          child: ListTile(
            leading: Icon(hasMatch ? Icons.person : Icons.person_outline),
            title: Text(role.name),
            subtitle: Text(subtitleText),
            onTap: () => onItemTap(role),
            trailing: IconButton(
              icon: const Icon(Icons.add, color: AppColors.primaryColor),
              onPressed: onAddTap,
            ),
          ),
        );
      },
    );
  }
}
