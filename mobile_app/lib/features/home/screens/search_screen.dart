import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:convert';
import '../../../core/constants.dart';
import '../widgets/empty_search_widget.dart';
import '../../../core/services/space_service.dart';
import '../../../core/models/space_model.dart';
import '../../booking/screens/space_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final SpaceService _spaceService = SpaceService();
  List<Space> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    // Debounce to avoid hitting API on every keystroke
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _isLoading = true);
      
      final results = await _spaceService.getSpaces(query: query);
      
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppConstants.primaryColor, onPressed: () => Get.back()),
        title: const Text("Search", style: TextStyle(color: Color(0xFFE0CFA0), fontFamily: 'Serif')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Search spaces...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                  onPressed: () {
                     _searchController.clear();
                     _onSearchChanged("");
                  },
                ),
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
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
                  : (_searchResults.isEmpty && _searchController.text.isNotEmpty)
                      ? const Center(child: Text("No spaces found", style: TextStyle(color: Colors.grey)))
                      : (_searchResults.isEmpty && _searchController.text.isEmpty)
                          ? const EmptySearchWidget()
                          : _buildResultsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final space = _searchResults[index];
        return _buildResultItem(space);
      },
    );
  }

  Widget _buildResultItem(Space space) {
    return GestureDetector(
      onTap: () {
        Get.to(() => SpaceDetailsScreen(space: space));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
             Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: _getImageProvider(space),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    space.title, 
                    style: const TextStyle(color: Color(0xFFE0CFA0), fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Serif'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppConstants.primaryColor, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          space.location, 
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey, fontSize: 12)
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "\$${space.price}/night",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  ImageProvider _getImageProvider(Space space) {
    if (space.images.isNotEmpty) {
       try {
        if (space.images.first.startsWith('http')) {
          return NetworkImage(space.images.first);
        }
        return MemoryImage(base64Decode(space.images.first));
      } catch (e) {
        return const NetworkImage("https://images.unsplash.com/photo-1522202176988-66273c2fd55f");
      }
    }
    return const NetworkImage("https://images.unsplash.com/photo-1522202176988-66273c2fd55f");
  }
}
