import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants.dart';
import '../../../core/models/booking_model.dart';

class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({super.key});

  @override
  State<BookingManagementScreen> createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> {
  List<Booking> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/bookings'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _bookings = data.map((json) => Booking.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load bookings: ${response.statusCode}')));
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading bookings: $e')));
      }
    }
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      await http.put(
        Uri.parse('${AppConstants.baseUrl}/bookings/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': newStatus}),
      );
      _fetchBookings();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating status: $e')));
      }
    }
  }

  Future<void> _deleteBooking(String id) async {
     final prefs = await SharedPreferences.getInstance();
     final token = prefs.getString('token');

     try {
       final response = await http.delete(
         Uri.parse('${AppConstants.baseUrl}/bookings/$id'),
         headers: {'Authorization': 'Bearer $token'},
       );

       if (response.statusCode == 200) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking deleted successfully')));
         }
         _fetchBookings();
       } else {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: ${response.statusCode}')));
         }
       }
     } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting: $e')));
       }
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Bookings')),
      body: RefreshIndicator(
        onRefresh: _fetchBookings,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _bookings.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 100),
                      Center(child: Text("No bookings found")),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final booking = _bookings[index];
                      return Card(
                        color: AppConstants.surfaceColor,
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Text(
                                          "Space: ${booking.space?.title ?? 'Unknown'}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteBooking(booking.id),
                                  ),
                                ],
                              ),
                              Text("User: ${booking.user?.name ?? 'Unknown'}",
                                  style: const TextStyle(color: Colors.grey)),
                              Text("Status: ${booking.status}",
                                  style: TextStyle(
                                      color: booking.status == 'confirmed'
                                          ? Colors.green
                                          : Colors.orange)),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  if (booking.status != 'confirmed')
                                    TextButton(
                                      onPressed: () =>
                                          _updateStatus(booking.id, 'confirmed'),
                                      child: const Text("Confirm",
                                          style: TextStyle(color: Colors.green)),
                                    ),
                                  if (booking.status != 'cancelled')
                                    TextButton(
                                      onPressed: () =>
                                          _updateStatus(booking.id, 'cancelled'),
                                      child: const Text("Cancel Status",
                                          style:
                                              TextStyle(color: Colors.orange)),
                                    ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
