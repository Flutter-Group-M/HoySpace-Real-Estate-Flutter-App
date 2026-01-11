import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/services/booking_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

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

  Widget _buildBookingsList(List<Booking> allBookings, {required bool isHistory}) {
    final filteredBookings = allBookings.where((b) {
      final now = DateTime.now();
      // Simple logic: History if checkout passed or status completed/cancelled
      // Upcoming if status confirmed/pending and checkin in future
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
                    child: Image.network(
                      image.startsWith('http') ? image : "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267",
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(height: 120, color: Colors.grey, child: const Icon(Icons.error)),
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
