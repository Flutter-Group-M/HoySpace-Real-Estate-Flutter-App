import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../auth/services/auth_service.dart';
import 'package:get/get.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../booking/screens/my_bookings_screen.dart'; // Import

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.surfaceColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppConstants.primaryColor,
                    radius: 30,
                    child: const Icon(Icons.person, color: Colors.black, size: 30),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "HoySpace User",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Welcome back",
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 50),
            // Menu Items
            _buildMenuItem(Icons.home, "Home", () {
             Get.back(); // ZoomDrawer close
            }),
            _buildMenuItem(Icons.event_available, "My Bookings", () { // New Item
              Get.to(() => const MyBookingsScreen());
            }),
            _buildMenuItem(Icons.person, "Profile", () {
              // Navigation logic can be added here or handled by changing the MainScreen index via a controller if desired.
              // For now, let's just close drawer or do nothing as an example.
            }),
            _buildMenuItem(Icons.settings, "Settings", () {}),
            const Spacer(),
            _buildMenuItem(Icons.logout, "Logout", () async {
              await AuthService().logout();
              Get.offAll(() => const OnboardingScreen());
            }),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }
}
