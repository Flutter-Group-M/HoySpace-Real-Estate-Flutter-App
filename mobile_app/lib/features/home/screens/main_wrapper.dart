import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import '../../../../core/constants.dart';
import 'package:get/get.dart';
import 'home_screen.dart';
import 'menu_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  final ZoomDrawerController _drawerController = ZoomDrawerController();

  @override
  void initState() {
    super.initState();
    // Inject controller for access in child screens
    Get.put<ZoomDrawerController>(_drawerController);
  }

  @override
  void dispose() {
    // Clean up if needed, though simple Get.put persists usually. 
    // For explicit cleanup: Get.delete<ZoomDrawerController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      controller: _drawerController,
      menuScreen: const MenuScreen(),
      mainScreen: const HomeScreen(),
      borderRadius: 24.0,
      showShadow: true,
      angle: -12.0,
      drawerShadowsBackgroundColor: Colors.grey.withOpacity(0.5),
      slideWidth: MediaQuery.of(context).size.width * 0.65,
      menuBackgroundColor: AppConstants.surfaceColor,
      mainScreenScale: 0.2, // Fixed: 0.1 was too small/subtle
    );
  }
}
