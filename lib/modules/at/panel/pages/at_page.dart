import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apptalma_v9/core/theme/app_colors.dart';
import 'package:apptalma_v9/core/providers/drawer_params_provider.dart';
import 'package:apptalma_v9/shared/widgets/submenu_drawer_widget.dart';

class AtHomePage extends StatefulWidget {
  const AtHomePage({super.key});

  @override
  State<AtHomePage> createState() => _AtHomePageState();
}

class _AtHomePageState extends State<AtHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final drawerParams = Provider.of<DrawerParamsProvider>(context);

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
          const SizedBox(width: 16),
        ],
      ),
      body: const Center(
        child: Text(
          "Bienvenido a la sección AT",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
