<<<<<<< HEAD
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import 'user_management_screen.dart';
import 'space_management_screen.dart';
import 'booking_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Timer? _timer;
  int _lastBookingCount = -1; // Initial state

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // Poll every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) _checkBookings();
    });
    // Initial check
    _checkBookings();
  }

  Future<void> _checkBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/bookings'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final currentCount = data.length;

        if (_lastBookingCount != -1 && currentCount > _lastBookingCount) {
          // New Booking Detected!
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("New Booking Received! Total: $currentCount"),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'VIEW',
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingManagementScreen()));
                  },
                ),
              ),
            );
          }
        }
        _lastBookingCount = currentCount;
      }
    } catch (e) {
      // Silent error, don't annoy admin
      print("Polling Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppConstants.backgroundColor,
        foregroundColor: AppConstants.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildAdminCard(
              context,
              'Manage Users',
              Icons.people,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementScreen())),
            ),
            const SizedBox(height: 16),
            _buildAdminCard(
              context,
              'Manage Spaces',
              Icons.apartment,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SpaceManagementScreen())),
            ),
            const SizedBox(height: 16),
            _buildAdminCard(
              context,
              'Manage Bookings',
              Icons.calendar_today,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingManagementScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppConstants.primaryColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppConstants.primaryColor, size: 30),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}
=======
>>>>>>> 04963835ad5d645256d805f2fa10189e248a98cb
