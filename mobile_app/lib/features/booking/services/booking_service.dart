import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants.dart';

class BookingService {
  Future<bool> createBooking({
    required String spaceId,
    required String checkIn,
    required String checkOut,
    required double totalPrice,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'spaceId': spaceId,
          'checkIn': checkIn,
          'checkOut': checkOut,
          'totalPrice': totalPrice,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print("Create Booking Failed: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      print("Create Booking Error: $e");
      return false;
    }
  }
}
