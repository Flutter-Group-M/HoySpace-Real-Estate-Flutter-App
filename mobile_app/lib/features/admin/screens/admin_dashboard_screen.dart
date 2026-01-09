import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Ensure these imports match your actual file locations
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
  int _lastBookingCount = -1; // Initial state to track booking changes

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Stop the timer when leaving the screen
    super.dispose();
  }

  void _startPolling() {
    // Poll every 10 seconds to check for new data
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) _checkBookings();
    });
    // Run an immediate check on load
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

        // If we have a previous count and the new count is higher -> New Booking!
        if (_lastBookingCount != -1 && currentCount > _lastBookingCount) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("🔔 New Booking Received! Total: $currentCount"),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'VIEW',
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const BookingManagementScreen()),
                    );
                  },
                ),
              ),
            );
          }
        }
        // Update the tracker
        _lastBookingCount = currentCount;
      }
    } catch (e) {
      // Silent error catching to prevent admin annoyance
      debugPrint("Polling Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark theme background
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.black,
        foregroundColor: AppConstants.primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Manage Users Card
            _buildAdminCard(
              context,
              'Manage Users',
              Icons.people,
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const UserManagementScreen())),
            ),
            const SizedBox(height: 16),

            // 2. Manage Spaces Card
            _buildAdminCard(
              context,
              'Manage Spaces',
              Icons.apartment,
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SpaceManagementScreen())),
            ),
            const SizedBox(height: 16),

            // 3. Manage Bookings Card
            _buildAdminCard(
              context,
              'Manage Bookings',
              Icons.calendar_today,
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const BookingManagementScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor, // Ensure this exists in constants
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppConstants.primaryColor.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppConstants.primaryColor, size: 28),
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}