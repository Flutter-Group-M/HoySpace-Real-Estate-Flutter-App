import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../widgets/empty_search_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  bool _hasResults = true; // State to toggle between list and empty state for demo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppConstants.primaryColor),
        title: const Text("Search", style: TextStyle(color: Color(0xFFE0CFA0), fontFamily: 'Serif')), // Beige title
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                // Mock logic: if query is "empty", show empty state
                setState(() {
                  _hasResults = value.toLowerCase() != "empty";
                });
              },
              decoration: InputDecoration(
                hintText: "Search...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                  onPressed: () {
                     _searchController.clear();
                     setState(() => _hasResults = true);
                  },
                ),
                filled: true,
                fillColor: const Color(0xFF2A2A2A), // Darker grey
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
              child: _hasResults ? _buildResultsList() : const EmptySearchWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView(
      children: [
        _buildResultItem("Cassablanca Ground", "Jidkasodonka Street 90, Hawlwdaag"),
        _buildResultItem("Songgoroti Villa", "MakaAlmukarama Street 68, Hawlwdaag"),
        _buildResultItem("The Ground Palace", "Isgoyska Bakaraha Street 3, Hawlwdaag"),
      ],
    );
  }

  Widget _buildResultItem(String title, String address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const Icon(Icons.home_outlined, color: AppConstants.primaryColor, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: const TextStyle(color: Color(0xFFE0CFA0), fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Serif')
                ),
                Text(
                  address, 
                  style: const TextStyle(color: Colors.grey, fontSize: 14)
                ),
              ],
            ),
          ),
          const Icon(Icons.near_me_outlined, color: AppConstants.primaryColor),
        ],
      ),
    );
  }
}
