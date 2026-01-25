import 'space_model.dart';
import 'user_model.dart';

class Booking {
  final String id;
  final User? user;
  final Space? space;
  final DateTime checkIn;
  final DateTime checkOut;
  final double totalPrice;
  final String status;

  Booking({
    required this.id,
    this.user,
    this.space,
    required this.checkIn,
    required this.checkOut,
    required this.totalPrice,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      user: (json['user'] != null && json['user'] is Map) 
          ? User.fromJson(json['user']) 
          : null,
      space: (json['space'] != null && json['space'] is Map) 
          ? Space.fromJson(json['space']) 
          : null,
      checkIn: DateTime.tryParse(json['checkIn']?.toString() ?? '') ?? DateTime.now(),
      checkOut: DateTime.tryParse(json['checkOut']?.toString() ?? '') ?? DateTime.now().add(const Duration(days: 1)),
      totalPrice: double.tryParse(json['totalPrice']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'pending',
    );
  }
}
