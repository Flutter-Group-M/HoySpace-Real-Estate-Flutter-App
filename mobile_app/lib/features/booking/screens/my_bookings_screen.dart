import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../core/constants.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/services/booking_service.dart';

class MyBookingsScreen extends StatefulWidget {
  final int initialIndex;
  const MyBookingsScreen({super.key, this.initialIndex = 0});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  late Future<List<Booking>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = BookingService().getBookings();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initialIndex,
      length: 2,
      child: Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        appBar: AppBar(
          title: const Text("My Bookings"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: AppConstants.primaryColor,
            labelColor: AppConstants.primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.event_available), text: "Upcoming"),
              Tab(icon: Icon(Icons.history), text: "History"),
            ],
          ),
        ),
        body: FutureBuilder<List<Booking>>(
          future: _bookingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No bookings found", style: TextStyle(color: Colors.grey)));
            }

            final bookings = snapshot.data!;

            return TabBarView(
              children: [
                _buildBookingsList(bookings, isHistory: false),
                _buildBookingsList(bookings, isHistory: true),
              ],
            );
          },
        ),
      ),
    );
  }

  // Helper for safe image loading
  ImageProvider _getImageProvider(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const AssetImage('assets/images/placeholder.jpg'); 
    }
    try {
      if (imageUrl.startsWith('http')) {
        return NetworkImage(imageUrl);
      } else {
         // Assuming Base64
         String base64String = imageUrl;
         if (imageUrl.contains(',')) {
           base64String = imageUrl.split(',').last;
         }
         return MemoryImage(base64Decode(base64String));
      }
    } catch (e) {
      return const AssetImage('assets/images/placeholder.jpg'); 
    }
  }

  Widget _buildBookingsList(List<Booking> allBookings, {required bool isHistory}) {
    final filteredBookings = allBookings.where((b) {
      final now = DateTime.now();
      if (isHistory) {
         return b.status == 'completed' || b.status == 'cancelled' || b.checkOut.isBefore(now);
      } else {
         return (b.status == 'confirmed' || b.status == 'pending') && b.checkOut.isAfter(now);
      }
    }).toList();

    if (filteredBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 60, color: Colors.grey.shade700),
            const SizedBox(height: 16),
            Text(
              isHistory ? "No past bookings" : "No upcoming bookings",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredBookings.length,
      itemBuilder: (context, index) {
        final booking = filteredBookings[index];
        final isCompleted = booking.status == 'completed';
        final image = (booking.space?.images.isNotEmpty ?? false) ? booking.space!.images[0] : "";
        final title = booking.space?.title ?? "Unknown Space";
        
        return Card(
          color: AppConstants.surfaceColor,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              // Image and Status
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: _getImageProvider(image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green : Colors.amber,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        booking.status.toUpperCase(),
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          "${booking.checkIn.toString().split(" ")[0]} - ${booking.checkOut.toString().split(" ")[0]}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                     const SizedBox(height: 4),
                     Text(
                      "Total: \$${booking.totalPrice.toStringAsFixed(0)}",
                      style: const TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
