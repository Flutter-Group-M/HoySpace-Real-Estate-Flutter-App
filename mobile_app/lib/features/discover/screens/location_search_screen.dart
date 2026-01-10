import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

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
          "Where To?",
          style: TextStyle(
            color: Color(0xFFE0CFA0), // Gold/Beige color
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search Location...",
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: Colors.grey),
                  onPressed: () => _searchController.clear(),
                ),
                filled: true,
                fillColor: AppConstants.surfaceColor,
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
              ),
            ),
            const SizedBox(height: 20),

            // Map Area
            Expanded(
              child: Stack(
                children: [
                   Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppConstants.primaryColor),
                      image: const DecorationImage(
                        image: NetworkImage("https://images.unsplash.com/photo-1524661135-423995f22d0b"), // Map Placeholder
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Pin
                  const Center(
                    child: Icon(Icons.location_on, color: AppConstants.primaryColor, size: 48),
                  ),
                  
                  // Zoom Controls
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Column(
                      children: [
                        _buildZoomButton(Icons.add),
                        const SizedBox(height: 8),
                         _buildZoomButton(Icons.remove),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Buttons
             SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                   // Set Location Logic
                   Navigator.pop(context, _searchController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Set Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
             SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                   _searchController.clear();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppConstants.primaryColor),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Reset Location', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.amber),
      ),
      child: Icon(icon, color: AppConstants.primaryColor),
    );
  }
}
