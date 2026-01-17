import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class PaymentMethodsListScreen extends StatelessWidget {
  const PaymentMethodsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Payment Methods", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: const BackButton(color: AppConstants.primaryColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Payment Card Item
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppConstants.primaryColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.credit_card, color: Colors.orange, size: 32),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Mastercard", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text("**** **** **** 9018", style: TextStyle(color: Colors.grey[400])),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.check_circle, color: AppConstants.primaryColor),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Add New Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, color: AppConstants.primaryColor),
                label: const Text("Add New Card", style: TextStyle(color: Colors.white)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppConstants.primaryColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
