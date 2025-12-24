import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:apptalma_v9/core/theme/app_colors.dart';
import 'package:apptalma_v9/core/theme/talma_custom_theme.dart';
import 'package:apptalma_v9/core/providers/user_provider.dart';
import 'package:apptalma_v9/core/providers/drawer_params_provider.dart';
import 'package:apptalma_v9/shared/widgets/submenu_drawer_widget.dart';
import 'package:apptalma_v9/modules/at/assigned-services/controller/assigned_services_controller.dart';
import 'package:apptalma_v9/modules/at/assigned-services/data/models/ground_services_model.dart';

class AssignedServicesPage extends StatefulWidget {
  const AssignedServicesPage({super.key});

  @override
  State<AssignedServicesPage> createState() => _AssignedServicesPageState();
}

class _AssignedServicesPageState extends State<AssignedServicesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final GroundServicesController _controller = GroundServicesController();
  List<GroundServices> _groundServices = [];
  bool _loading = false;

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _fetchGroundServices({bool showLoading = false}) async {
    try {
      if (showLoading) setState(() => _loading = true);

      final user = Provider.of<UserProvider>(context, listen: false).user;

      if (user?.employeeId == null || user!.employeeId.isEmpty) {
        throw Exception("El usuario no tiene un EmployeeId válido");
      }

      final myGroundServices =
          await _controller.getGroundServicesToUser(user.employeeId);

      setState(() {
        _groundServices = myGroundServices;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _groundServices = [];
        _loading = false;
      });
    }
  }

  Future<void> _loadData() async {
    await _fetchGroundServices(showLoading: true);
  }

  Future<void> _refresh() async {
    await _fetchGroundServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final drawerParams = Provider.of<DrawerParamsProvider>(context);

    final filteredItems = _groundServices
        .where((item) =>
            item.incomingFlight
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            item.outgoingFlight
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            item.origin.toLowerCase().contains(searchQuery.toLowerCase()) ||
            item.destiny.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.85,
        child: SubMenuDrawer(
          subItems: drawerParams.subItems,
          onItemTap: (item) => Navigator.pop(context),
          userName: drawerParams.userName,
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu_open),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Container(
            color: AppColors.primaryColor,
            height: 5.0,
          ),
        ),
        elevation: 0,
        title: LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = MediaQuery.of(context).size.width;
            final double imageWidth = screenWidth * 0.3;
            return Image.asset(
              'assets/images/logo_talma_2.png',
              width: imageWidth,
              fit: BoxFit.contain,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.grey),
            onPressed: () {},
          ),
          CircleAvatar(
            backgroundColor: AppColors.primaryColor,
            child: Text(
              "${(user?.name.isNotEmpty == true ? user!.name[0] : '')}"
              "${(user?.lastName.isNotEmpty == true ? user!.lastName[0] : '')}",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Título
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[100],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.airline_stops_outlined,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    Text(
                      "Servicios Asignados",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 🔹 Campo de búsqueda
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: "Buscar...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) => setState(() => searchQuery = value),
                ),
                const SizedBox(height: 16),

                // 🔹 Lista de servicios
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final service = filteredItems[index];
                          final staTime = DateTime.parse(service.vta);
                          final stdTime = DateTime.parse(service.vtd);
                          final DateTime nowDate = DateTime.now();

                          final bool dayMore =
                              _controller.isNextDay(nowDate, stdTime);
                          final DateTime rangeArrival =
                              nowDate.subtract(const Duration(minutes: 20));

                          final bool viewBorder =
                              staTime.isAfter(rangeArrival) &&
                                  staTime.isBefore(nowDate);

                          final isArrived = service.ata.trim().isNotEmpty;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: InkWell(
                              onTap: () {
                                context.push(
                                  "/detail-service",
                                  extra: service,
                                );
                              },
                              child: Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: viewBorder
                                      ? const BorderSide(
                                          color: Colors.green, width: 5)
                                      : BorderSide.none,
                                ),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 15),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          'https://content.airhex.com/content/logos/airlines_${service.company}_40_40_s.png',
                                          width: 30,
                                          height: 30,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(
                                                Icons.broken_image,
                                                size: 30);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          service
                                                              .incomingFlight,
                                                          style: isArrived
                                                              ? Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .disabledTitleLg
                                                              : Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .atFlightNumber,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                            service.gate,
                                                            style: Theme.of(
                                                                    context)
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
                                                          service.origin,
                                                          style: isArrived
                                                              ? Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .disabledTitleMd
                                                              : Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .atFlightIata,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                            DateFormat.Hm()
                                                                .format(
                                                                    staTime),
                                                            style: isArrived
                                                                ? Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .disabledTitleMd
                                                                : Theme.of(
                                                                        context)
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
                                              height: 40,
                                              color: Colors.grey,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15),
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          service
                                                              .outgoingFlight,
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .atFlightNumber,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                            service.gate,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .atParking,
                                                          ),
                                                        ),
                                                      ),
                                                      if (service.flightNotes
                                                          .trim()
                                                          .isNotEmpty)
                                                        const Icon(
                                                          Icons.circle,
                                                          color: Colors.red,
                                                          size: 15,
                                                        )
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          service.destiny,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .atFlightIata,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: RichText(
                                                            text: TextSpan(
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .atFlightTime,
                                                              children: [
                                                                TextSpan(
                                                                    text: DateFormat
                                                                            .Hm()
                                                                        .format(
                                                                            stdTime)),
                                                                if (dayMore)
                                                                  const TextSpan(
                                                                    text: '+1',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .blue,
                                                                        fontSize:
                                                                            14),
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
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
