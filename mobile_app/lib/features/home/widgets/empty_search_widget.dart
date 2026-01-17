import 'package:flutter/material.dart';
import '../../../../core/constants.dart';

class EmptySearchWidget extends StatelessWidget {
  const EmptySearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Huge Search Function
         Stack(
           alignment: Alignment.center,
           children: [
              Icon(Icons.search, size: 120, color: AppConstants.primaryColor.withOpacity(0.2)), 
              const Icon(Icons.search, size: 120, color: AppConstants.primaryColor),
           ],
         ),
        const SizedBox(height: 24),
        const Text(
          "The Place Dosent Exist",
          style: TextStyle(
            color: Color(0xFFE0CFA0),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif',
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Try searching a different keywords for\nthe best results.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }
}
