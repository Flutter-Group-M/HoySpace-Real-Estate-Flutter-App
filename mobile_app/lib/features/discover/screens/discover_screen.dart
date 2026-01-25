import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/services/space_service.dart';
import '../../../core/models/space_model.dart';
import '../../booking/screens/space_details_screen.dart';
import 'location_search_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final List<String> _categories = ["All", "Hotel", "Apartment", "Guest House", "Beachfront", "Cabin", "Trending", "Luxury", "Mansions", "Islands", "Camping"];
  int _selectedCategoryIndex = 0;
  String _currentLocation = "Mogadishu, Banaadir, Somalia"; // Default
  
  List<Space> _allSpaces = [];
  List<Space> _filteredSpaces = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSpaces();
  }

  Future<void> _fetchSpaces({String? location, String? query}) async {
    setState(() => _isLoading = true);
    // If we have a query (keyword), we treat it as a generic search (which now includes location check in backend)
    // If we have a location (explicit), we filter by location specifically
    
    // Note: SpaceService maps 'query' to 'search' param
    final spaces = await SpaceService().getSpaces(location: location, query: query);
    
    if (mounted) {
      setState(() {
        _allSpaces = spaces;
        _filteredSpaces = spaces; // Reset filter on new fetch
        _isLoading = false;
        
        // Only update header if it's an explicit location selection
        if (location != null) {
          _currentLocation = location;
        } else if (query != null && query.isNotEmpty) {
           // Optional: Reset header or show "Searching: $query"
           // For now, let's keep the last known location or default
        }
      });
      // Re-apply category filter check
      if (_selectedCategoryIndex != 0) {
        _filterSpaces(_selectedCategoryIndex);
      }
    }
  }

  void _filterSpaces(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      final category = _categories[index];
      
      if (category == "All") {
        _filteredSpaces = _allSpaces;
      } else {
        _filteredSpaces = _allSpaces.where((space) {
          return space.category == category || 
                 space.title.toLowerCase().contains(category.toLowerCase()) || 
                 space.description.toLowerCase().contains(category.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Where To?
                const Text(
                  "Where To?", 
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                          Text(
                          _currentLocation, 
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.keyboard_arrow_down, color: AppConstants.primaryColor),
                      ],
                    ),
                    const Column(
                      children: [
                          Icon(Icons.home_filled, color: AppConstants.primaryColor, size: 20),
                          Text("HoySpace", style: TextStyle(color: Colors.white, fontSize: 8)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 20),

                // Search Bar Linked to LocationSearchScreen
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LocationSearchScreen()),
                    );
                    
                    if (result != null && result is Map) {
                       final query = result['query'];
                       final type = result['type'];
                       
                       if (type == 'location') {
                         _fetchSpaces(location: query);
                       } else {
                         _fetchSpaces(query: query);
                       }
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search Spaces...",
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF2A2A2A),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
                          borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Categories
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_categories.length, (index) {
                      final isSelected = _selectedCategoryIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: InkWell(
                          onTap: () => _filterSpaces(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppConstants.primaryColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppConstants.primaryColor),
                            ),
                            child: Text(
                              _categories[index],
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),

                // Results Section
                _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
                  : _filteredSpaces.isEmpty
                      ? const Center(child: Text("No spaces found in this category.", style: TextStyle(color: Colors.grey)))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle("Available Spaces"),
                            const SizedBox(height: 12),
                            _buildHorizontalSpaceList(_filteredSpaces),
                          ],
                        ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFE0CFA0), // Gold text
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif',
          ),
        ),
        const Icon(Icons.chevron_right, color: Colors.white),
      ],
    );
  }

  Widget _buildHorizontalSpaceList(List<Space> spaces) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: spaces.length,
        itemBuilder: (context, index) {
          final space = spaces[index];
          final image = space.images.isNotEmpty ? space.images[0] : "";

          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppConstants.primaryColor),
              color: AppConstants.surfaceColor,
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SpaceDetailsScreen(
                    space: space,
                  )),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                        image: DecorationImage(
                          image: _getImageProvider(image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Info
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          space.title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "\$${space.price.toStringAsFixed(0)} / Night",
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                         Row(
                           children: const [
                             Icon(Icons.star, color: Colors.white, size: 14),
                             SizedBox(width: 4),
                             Text("5.0", style: TextStyle(color: Colors.white, fontSize: 12)),
                           ],
                         )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  ImageProvider _getImageProvider(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const NetworkImage("https://images.unsplash.com/photo-1566073771259-6a8506099945");
    }
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      return NetworkImage(imageUrl);
    }
    try {
      return MemoryImage(base64Decode(imageUrl));
    } catch (e) {
      print("Error decoding base64 image: $e");
      return const NetworkImage("https://images.unsplash.com/photo-1566073771259-6a8506099945");
    }
  }
}
