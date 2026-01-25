import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/services/auth_service.dart';
import 'edit_profile_screen.dart';
import 'payment_methods_list_screen.dart';
import 'booking_history_screen.dart';
import '../../booking/screens/my_bookings_screen.dart';
import 'notifications_screen.dart';
import 'security_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = "Loading...";
  String _email = "Loading...";
  String? _imageUrl;
  
  // Stats
  String _bookings = "0";
  String _reviews = "0";
  String _saved = "0";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Fetch live stats
    final stats = await AuthService().getUserStats();

    setState(() {
      _userName = prefs.getString('userName') ?? "User Name";
      _email = prefs.getString('email') ?? "user@example.com"; 
      _imageUrl = prefs.getString('image'); 
      
      _bookings = stats['bookings'].toString();
      _reviews = stats['reviews'].toString();
      _saved = stats['saved'].toString();
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (context) => const LoginScreen()), 
      (route) => false
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        // leading: const BackButton(color: AppConstants.primaryColor), // Removed forced back button
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Profile Header
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                            _loadUserData();
                          },
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppConstants.primaryColor, width: 2),
                              image: DecorationImage(
                                image: _getImageProvider(_imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppConstants.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: GestureDetector(
                              onTap: () async {
                                await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                                _loadUserData();
                              },
                              behavior: HitTestBehavior.opaque,
                              child: const Icon(Icons.edit, size: 14, color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _userName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      _email,
                      style: TextStyle(color: AppConstants.secondaryTextColor, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Stats Row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppConstants.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem("Bookings", _bookings),
                    Container(height: 40, width: 1, color: Colors.grey),
                    _buildStatItem("Reviews", _reviews),
                    Container(height: 40, width: 1, color: Colors.grey),
                    _buildStatItem("Saved", _saved),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Menu Options
              _buildProfileOption(
                context, 
                Icons.person_outline, 
                "Edit Profile",
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                  _loadUserData();
                },
              ),
              _buildProfileOption(
                context, 
                Icons.payment, 
                "Payment Methods",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentMethodsListScreen())),
              ),
              _buildProfileOption(
                context, 
                Icons.history, 
                "Booking History",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BookingHistoryScreen())),
              ),
              _buildProfileOption(
                context, 
                Icons.notifications_outlined, 
                "Notifications",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
              ),
              _buildProfileOption(
                context, 
                Icons.security, 
                "Security",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityScreen())),
              ),
              _buildProfileOption(
                context, 
                Icons.logout, 
                "Log Out", 
                isDestructive: true,
                onTap: () async {
                  await AuthService().logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
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

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppConstants.primaryColor)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildProfileOption(BuildContext context, IconData icon, String title, {bool isDestructive = false, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap ?? () {},
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.withOpacity(0.1) : AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isDestructive ? Colors.red : AppConstants.primaryColor),
      ),
      title: Text(
        title, 
        style: TextStyle(
          fontWeight: FontWeight.w500, 
          color: isDestructive ? Colors.red : Colors.white,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }
}
