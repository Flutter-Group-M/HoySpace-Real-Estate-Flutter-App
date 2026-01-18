import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import 'payment_method_screen.dart';

class PaymentInfoScreen extends StatefulWidget {
  final double price;
  final String spaceId;
  final DateTime checkIn;
  final DateTime checkOut;

  const PaymentInfoScreen({
    super.key, 
    required this.price,
    required this.spaceId,
    required this.checkIn,
    required this.checkOut,
  });

  @override
  State<PaymentInfoScreen> createState() => _PaymentInfoScreenState();
}

class _PaymentInfoScreenState extends State<PaymentInfoScreen> {
  // Controllers
  final _nameController = TextEditingController(text: "Sharmake Hassan"); // Pre-filled from design
  final _phoneController = TextEditingController(text: "+252611688269");
  final _memberController = TextEditingController(text: "2 Member");
  final _idController = TextEditingController(text: "349812470598137");

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
        title: const Text(
          "Payment Method", // Keeping title from design even though it's info
          style: TextStyle(
            color: Color(0xFFE0CFA0),
            fontFamily: 'Serif',
            fontWeight: FontWeight.bold,
          ),
        ),
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
                  _buildLabel("Full Name"),
                  _buildTextField(_nameController),
                  const SizedBox(height: 20),

                  _buildLabel("Active Phone Number"),
                  _buildTextField(_phoneController),
                  const SizedBox(height: 20),

                  _buildLabel("How Much Member"),
                  _buildTextField(_memberController),
                  const SizedBox(height: 20),

                  _buildLabel("ID Card Number"),
                  _buildTextField(_idController),
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
                       "\$${widget.price.toStringAsFixed(0)} / total", // Using int format from design
                       style: const TextStyle(
                         color: Colors.white,
                         fontSize: 18, 
                         fontWeight: FontWeight.bold
                       ),
                     ),
                   ],
                 ),
                 ElevatedButton(
                   onPressed: () {
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => PaymentMethodScreen(
                          price: widget.price,
                          spaceId: widget.spaceId,
                          checkIn: widget.checkIn,
                          checkOut: widget.checkOut,
                        )),
                     );
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: AppConstants.primaryColor,
                     foregroundColor: Colors.black,
                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                   ),
                   child: const Text("Payment Method", style: TextStyle(fontWeight: FontWeight.bold)),
                 ),
               ],
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label, 
        style: const TextStyle(color: Colors.white, fontSize: 16)
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.grey),
      decoration: InputDecoration(
        filled: true,
         fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.primaryColor),
        ),
         focusedBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
