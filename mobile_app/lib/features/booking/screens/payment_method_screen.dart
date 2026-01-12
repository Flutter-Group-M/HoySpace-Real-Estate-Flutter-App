import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../common/screens/success_screen.dart';
import '../../../core/services/booking_service.dart';

class PaymentMethodScreen extends StatefulWidget {
  final double price;
  final String spaceId;
  final DateTime checkIn;
  final DateTime checkOut;

  const PaymentMethodScreen({
    super.key, 
    required this.price,
    required this.spaceId,
    required this.checkIn,
    required this.checkOut,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final _cardNumberController = TextEditingController(text: "465 323 123 9018");
  final _cvvController = TextEditingController(text: "3031");
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    // Simulate payment delay
    await Future.delayed(const Duration(seconds: 2));

    try {
      await BookingService().createBooking(
        widget.spaceId,
        widget.checkIn,
        widget.checkOut,
        widget.price,
      );

      if (mounted) {
        setState(() => _isProcessing = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SuccessScreen(message: "Successfully Booked a Space!")),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Booking Failed: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
         backgroundColor: Colors.transparent,
         elevation: 0,
         leading: IconButton(
           icon: const Icon(Icons.arrow_back, color: AppConstants.primaryColor),
           onPressed: () => Navigator.pop(context),
         ),
         title: const Text("Payment Method", style: TextStyle(color: Color(0xFFE0CFA0), fontFamily: 'Serif', fontWeight: FontWeight.bold)),
         centerTitle: true,
         actions: [
          Padding(
             padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.home_filled, color: AppConstants.primaryColor, size: 20),
                const Text("HoySpace", style: TextStyle(color: Colors.white, fontSize: 8)),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Visual Credit Card
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppConstants.primaryColor),
                      image: const DecorationImage(
                         image: NetworkImage("https://www.transparenttextures.com/patterns/cubes.png"),
                         fit: BoxFit.cover,
                         opacity: 0.1,
                      )
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Hasbi Arindra", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Master card", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                                Text("465 ••• ••• 9018", style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                              ],
                            ),
                            SizedBox(
                              width: 50,
                              height: 30,
                              child: Stack(
                                children: [
                                  Container(
                                    width: 30, height: 30,
                                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  ),
                                  Positioned(
                                    left: 15,
                                    child: Container(
                                      width: 30, height: 30,
                                      decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildLabel("Card Number"),
                  _buildTextField(_cardNumberController),
                  const SizedBox(height: 20),

                  _buildLabel("CVV"),
                  _buildTextField(_cvvController),
                ],
              ),
            ),
          ),

          // Bottom Bar
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
             decoration: const BoxDecoration(
               color: AppConstants.surfaceColor,
               border: Border(top: BorderSide(color: Colors.black12)),
             ),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   mainAxisSize: MainAxisSize.min,
                   children: [
                      Text(
                       "\$${widget.price.toStringAsFixed(0)} / total", 
                       style: const TextStyle(
                         color: Colors.white,
                         fontSize: 18, 
                         fontWeight: FontWeight.bold
                       ),
                     ),
                   ],
                 ),
                 _isProcessing 
                 ? const CircularProgressIndicator(color: AppConstants.primaryColor)
                 : ElevatedButton(
                   onPressed: _processPayment,
                   style: ElevatedButton.styleFrom(
                     backgroundColor: AppConstants.primaryColor,
                     foregroundColor: Colors.black,
                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                   ),
                   child: const Text("Process Payment", style: TextStyle(fontWeight: FontWeight.bold)),
                 ),
               ],
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)));
  }
   Widget _buildTextField(TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.grey),
      decoration: InputDecoration(
        filled: true,
         fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppConstants.primaryColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppConstants.primaryColor)),
         focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppConstants.primaryColor)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
