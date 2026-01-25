import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/services/booking_service.dart';
import 'dart:convert';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  late Future<List<Booking>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = BookingService().getBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text("Booking History"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppConstants.primaryColor),
      ),
      body: FutureBuilder<List<Booking>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No booking history found", style: TextStyle(color: Colors.grey)));
          }

          // Filter for history only (completed, cancelled, or past checkout)
          final now = DateTime.now();
          final historyBookings = snapshot.data!.where((b) {
            return b.status == 'completed' || b.status == 'cancelled' || b.checkOut.isBefore(now);
          }).toList();

          if (historyBookings.isEmpty) {
             return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 60, color: Colors.grey.shade700),
                  const SizedBox(height: 16),
                  Text(
                    "No booking history",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: historyBookings.length,
            itemBuilder: (context, index) {
              final booking = historyBookings[index];
              return _buildBookingCard(booking);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
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
                    color: isCompleted ? Colors.green : Colors.grey,
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
}
