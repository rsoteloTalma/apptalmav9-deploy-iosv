import 'package:flutter/material.dart';

import 'package:apptalma_v9/core/models/session.dart';
import 'package:apptalma_v9/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apptalma_v9/modules/general/flight-info/flight_info_main.dart';
import 'package:apptalma_v9/modules/general/panel/pages/panel_page.dart';
import 'package:apptalma_v9/modules/general/profile/profile_main.dart';

class PanelMain extends StatefulWidget {
  final Session sessionData;
  const PanelMain({super.key, required this.sessionData});

  @override
  State<PanelMain> createState() => _PanelMainState();
}

class _PanelMainState extends State<PanelMain> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) async {
    if (index == 3) {
      _showLogoutConfirmationDialog();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _showLogoutConfirmationDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Cerrar Sesión"),
          content:
              const Text("¿Estás seguro de que quieres finalizar tú sesión?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _logout();
              },
              child: const Text("Cerrar Sesión",
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("session");

    GoRouter.of(context).go('/');
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTablet = screenWidth >= 600;

    var pages = [
      PanelPage(sessionData: widget.sessionData),
      const FlightInfoMain(),
      ProfileMain(sessionData: widget.sessionData),
      Container(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(20),
          child: Container(
            color: AppColors.primaryColor,
            height: 5.0,
          ),
        ),
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = MediaQuery.of(context).size.width;
              double imageWidth = screenWidth * (isTablet ? 0.2 : 0.3);
              return Image.asset(
                'assets/images/logo_talma_2.png',
                width: imageWidth,
                fit: BoxFit.contain,
              );
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.grey),
            onPressed: () {},
          ),
          CircleAvatar(
            backgroundColor: AppColors.primaryColor,
            child: Text(
              "${widget.sessionData.user.name.substring(0, 1)}${widget.sessionData.user.lastName.substring(0, 1)}",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: SafeArea(
        child: FractionallySizedBox(
          widthFactor: isTablet ? 0.5 : 0.8,
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: AppColors.talmaCyan,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  iconSize: 28,
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: ''),
                    BottomNavigationBarItem(icon: Icon(Icons.airplanemode_active), label: ''),
                    BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
                    BottomNavigationBarItem(icon: Icon(Icons.logout), label: ''),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
