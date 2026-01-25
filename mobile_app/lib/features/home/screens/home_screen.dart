import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../../../core/constants.dart';
import '../../booking/screens/space_details_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../chat/screens/chat_screen.dart';
import '../../discover/screens/discover_screen.dart';
import '../../profile/screens/notifications_screen.dart';
import '../../auth/services/auth_service.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import 'search_screen.dart';
import 'filter_screen.dart'; // Import
import '../../../core/services/space_service.dart';
import '../../../core/models/space_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const DiscoverScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _selectedIndex,
        showElevation: true,
        itemCornerRadius: 24,
        curve: Curves.easeIn,
        backgroundColor: AppConstants.surfaceColor,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavyBarItem(
            icon: const Icon(Icons.home),
            title: const Text('Home'),
            activeColor: AppConstants.primaryColor,
            inactiveColor: Colors.grey,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.explore),
            title: const Text('Discover'),
            activeColor: AppConstants.primaryColor,
            inactiveColor: Colors.grey,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.chat_bubble_outline),
            title: const Text('Chat'),
            activeColor: AppConstants.primaryColor,
            inactiveColor: Colors.grey,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            activeColor: AppConstants.primaryColor,
            inactiveColor: Colors.grey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text("Hoy Space", style: TextStyle(fontSize: 14, color: Colors.grey)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 30,
                  width: 30,
                ),
                const SizedBox(width: 5),
                const Text("HoySpace", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppConstants.primaryColor),
          onPressed: () {
            if (ZoomDrawer.of(context) != null) {
              ZoomDrawer.of(context)!.toggle();
            } else {
               try {
                 Get.find<ZoomDrawerController>().toggle?.call();
               } catch (e) {
                 print("ZoomDrawer Toggle Error: $e");
               }
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppConstants.primaryColor),
            onPressed: () {
              Get.to(() => const NotificationsScreen());
            },
          ),
          FutureBuilder<bool>(
            future: AuthService().isAdmin(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data == true) {
                return IconButton(
                  icon: const Icon(Icons.admin_panel_settings, color: Colors.red),
                  onPressed: () {
                    Get.to(() => const AdminDashboardScreen());
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              GestureDetector(
                onTap: () {
                   Get.to(() => const SearchScreen());
                },
                child: AbsorbPointer( // Prevents keyboard from popping up here
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search Spaces...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.tune, color: AppConstants.primaryColor), // Filter icon
                        onPressed: () {
                           Get.to(() => const FilterScreen());
                        },
                      ),
                      filled: true,
                      fillColor: AppConstants.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppConstants.primaryColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // "Find Something Special" Banner
              Stack(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: NetworkImage("https://images.unsplash.com/photo-1518780664697-55e3ad937233"), // Placeholder modern building
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                      child: const Text("Unique", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("Find Something\nSpecial", 
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.transparent, 
                            border: Border.all(color: AppConstants.primaryColor),
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: const Icon(Icons.arrow_forward, color: AppConstants.primaryColor, size: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Popular Spaces Header
              const Text(
                "Popular Spaces",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Serif', color: Color(0xFFE0CFA0)),
              ),
              const SizedBox(height: 10),

              // Vertical List of Spaces (Real Data)
              FutureBuilder<List<Space>>(
                future: SpaceService().getSpaces(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
                  }
                  
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No spaces found.", style: TextStyle(color: Colors.grey)));
                  }

                  final spaces = snapshot.data!;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: spaces.length,
                    itemBuilder: (context, index) {
                      final space = spaces[index];
                      // Use the first image if available, else placeholder
                      final image = space.images.isNotEmpty ? space.images[0] : "";
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: AppConstants.surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppConstants.primaryColor.withOpacity(0.5)),
                        ),
                        child: InkWell(
                          onTap: () {
                             Get.to(
                                () => SpaceDetailsScreen(
                                  space: space,
                                ),
                              );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image
                              Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  image: DecorationImage(
                                    image: _getImageProvider(image),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "\$${space.price.toStringAsFixed(0)}", 
                                          style: const TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
                                        ),
                                        Row(
                                          children: const [
                                            Icon(Icons.star, color: AppConstants.primaryColor, size: 16),
                                            SizedBox(width: 4),
                                            Text("5.0", style: TextStyle(color: Colors.white)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const Text("per night", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    const SizedBox(height: 8),
                                    Text(
                                      space.title,
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Serif'),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 14, color: AppConstants.primaryColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          space.location, 
                                          style: const TextStyle(fontSize: 12, color: AppConstants.secondaryTextColor),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              ),
            ],
          ),
        ),
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

