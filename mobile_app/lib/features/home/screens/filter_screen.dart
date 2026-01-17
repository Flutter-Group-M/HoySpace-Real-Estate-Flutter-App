import 'package:flutter/material.dart';
import '../../../../core/constants.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // Amenities (CheckboxListTile)
  List<String> amenities = ['Wifi', 'Pool', 'Air Conditioning', 'Parking', 'Kitchen', 'Gym'];
  List<bool> selectedAmenities = [false, false, false, false, false, false];

  // Sort By (RadioListTile)
  String? sortBy = 'recommended';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text("Filters"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                selectedAmenities = List.filled(amenities.length, false);
                sortBy = 'recommended';
              });
            },
            child: const Text("Reset", style: TextStyle(color: AppConstants.primaryColor)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sort By Section (RadioListTile)
            const Text("Sort By", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildRadioTile("Recommended", "recommended"),
            _buildRadioTile("Price: Low to High", "price_asc"),
            _buildRadioTile("Price: High to Low", "price_desc"),
            const Divider(color: Colors.grey),
            
            const SizedBox(height: 20),

            // Amenities Section (CheckboxListTile)
            const Text("Amenities", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: amenities.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(amenities[index], style: const TextStyle(color: Colors.white)),
                  value: selectedAmenities[index],
                  activeColor: AppConstants.primaryColor,
                  checkColor: Colors.black,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) {
                    setState(() {
                      selectedAmenities[index] = value!;
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppConstants.surfaceColor,
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: ElevatedButton(
          onPressed: () {
            // Apply Filters logic -> Pass back data or use GetX controller
            Navigator.pop(context, {
              'sortBy': sortBy,
              'amenities': selectedAmenities,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Show Results", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildRadioTile(String title, String value) {
    return RadioListTile<String>(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      value: value,
      groupValue: sortBy,
      activeColor: AppConstants.primaryColor,
      onChanged: (String? newValue) {
        setState(() {
          sortBy = newValue;
        });
      },
    );
  }
}
