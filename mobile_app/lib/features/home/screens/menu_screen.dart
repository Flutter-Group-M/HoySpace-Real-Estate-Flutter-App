import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import '../../../core/constants.dart';
import '../../auth/services/auth_service.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../booking/screens/my_bookings_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../profile/screens/edit_profile_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _userName = "HoySpace User";
  String _email = "Welcome back";
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? "HoySpace User";
      _email = prefs.getString('email') ?? "Welcome back"; // Using email or fallback as subtitle
      _imageUrl = prefs.getString('image');
    });
  }

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
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppConstants.primaryColor, width: 2),
                      image: DecorationImage(
                        image: _getImageProvider(_imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _email,
                          style: TextStyle(color: Colors.grey[400], fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 50),
            // Menu Items
            _buildMenuItem(Icons.home, "Home", () {
              // Get.back(); // May pop screen instead of closing drawer
              Get.find<ZoomDrawerController>().close?.call();
            }),
            _buildMenuItem(Icons.event_available, "My Bookings", () {
              Get.to(() => const MyBookingsScreen());
            }),
            _buildMenuItem(Icons.person, "Profile", () {
              Get.to(() => const ProfileScreen())?.then((_) => _loadUserData());
            }),
            _buildMenuItem(Icons.settings, "Settings", () {
              Get.to(() => const EditProfileScreen())?.then((_) => _loadUserData());
            }),
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

  ImageProvider _getImageProvider(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const NetworkImage("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde");
    }
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      return NetworkImage(imageUrl);
    }
    try {
      return MemoryImage(base64Decode(imageUrl));
    } catch (e) {
      print("Error decoding base64 image: $e");
      return const NetworkImage("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde");
    }
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
