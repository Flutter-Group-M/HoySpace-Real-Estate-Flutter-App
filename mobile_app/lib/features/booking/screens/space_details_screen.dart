import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants.dart';
import '../../../core/models/space_model.dart'; // Import Space model
import '../../common/screens/success_screen.dart';
import 'payment_info_screen.dart';
import '../../chat/screens/conversation_screen.dart';

class SpaceDetailsScreen extends StatefulWidget {
  final Space space;

  const SpaceDetailsScreen({
    super.key,
    required this.space,
  });

  @override
  State<SpaceDetailsScreen> createState() => _SpaceDetailsScreenState();
}

class _SpaceDetailsScreenState extends State<SpaceDetailsScreen> {
  // Booking Date Controllers
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  bool _isAdmin = false;
  bool _isFavorite = false;
  
  // Expansion Logic
  List<Item> _expansionItems = [
    Item(header: "House Rules", body: "1. No smoking inside.\n2. No parties or events.\n3. Check-in after 2:00 PM."),
    Item(header: "Cancellation Policy", body: "Free cancellation until 24 hours before check-in."),
    Item(header: "Health & Safety", body: "Carbon monoxide alarm installed.\nSmoke alarm installed."),
  ];

  @override
  void initState() {
    super.initState();
    _checkRole();
    _checkFavorite();
  }

  Future<void> _checkRole() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isAdmin = prefs.getString('role') == 'admin';
      });
    }
  }

  Future<void> _checkFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSpaces = prefs.getStringList('savedSpaces') ?? [];
    if (mounted) {
      setState(() {
        _isFavorite = savedSpaces.contains(widget.space.id.toString());
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSpaces = prefs.getStringList('savedSpaces') ?? [];
    String spaceId = widget.space.id.toString();

    if (_isFavorite) {
      savedSpaces.remove(spaceId);
    } else {
      savedSpaces.add(spaceId);
    }

    await prefs.setStringList('savedSpaces', savedSpaces);
    
    if (mounted) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isFavorite ? "Added to favorites" : "Removed from favorites")),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppConstants.primaryColor,
              onPrimary: Colors.black,
              surface: AppConstants.surfaceColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toString().split(" ")[0];
      });
    }
  }

  // Helper for safe image loading
  ImageProvider _getImageProvider(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const AssetImage('assets/images/placeholder.jpg'); // Ensure you have a placeholder
    }
    try {
      if (imageUrl.startsWith('http')) {
        return NetworkImage(imageUrl);
      } else {
         // Assuming Base64
         // Remove header if present (e.g. "data:image/png;base64,")
         String base64String = imageUrl;
         if (imageUrl.contains(',')) {
           base64String = imageUrl.split(',').last;
         }
         // Validate Base64 length/padding
         // if (base64String.length % 4 != 0) { ... handle padding ... }
         
         // Using MemoryImage with safe decoding
         // Requires 'dart:convert';
         return MemoryImage(base64Decode(base64String));
      }
    } catch (e) {
      print("Error loading image: $e");
      return const AssetImage('assets/images/placeholder.jpg'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final space = widget.space;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsible App Bar with Image
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true, // App bar remains visible
            backgroundColor: AppConstants.backgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  image: space.images.isNotEmpty ? DecorationImage(
                      image: _getImageProvider(space.images[0]), // Safe Loader
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {
                        print("Image Load Error: $exception");
                      },
                  ) : null,
                ),
                child: space.images.isEmpty ? const Center(
                  child: Icon(Icons.image, size: 100, color: Colors.white),
                ) : null,
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
               Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: AppConstants.primaryColor),
                  onPressed: () {
                     if (_isAdmin) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Admins: Use the main Chat tab to view messages.")));
                       return;
                     }
                     if (space.hostId.isEmpty) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Host info not available")));
                       return;
                     }
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => ConversationScreen(
                         otherUserId: space.hostId,
                         otherUserName: space.hostName,
                         otherUserImage: space.hostImage,
                       )),
                     );
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: _isFavorite ? Colors.red : Colors.white),
                  onPressed: _toggleFavorite,
                ),
              ),
            ],
          ),

          // Details Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          space.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppConstants.primaryColor, size: 20),
                          const SizedBox(width: 4),
                          Text("4.8 (240 reviews)", style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppConstants.primaryColor, size: 16),
                      const SizedBox(width: 4),
                      Text(space.location, style: TextStyle(color: AppConstants.secondaryTextColor)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    space.description,
                    style: TextStyle(color: AppConstants.secondaryTextColor, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  
                  // Host Info
                  Row(
                    children: [
                      CircleAvatar(
                         backgroundColor: Colors.grey.shade800,
                         backgroundImage: _getImageProvider(space.hostImage), // Safe Loader
                         child: space.hostImage.isEmpty ? Text(space.hostName.isNotEmpty ? space.hostName[0] : "H", style: const TextStyle(color: Colors.white)) : null,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Hosted by ${space.hostName}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const Text("Superhost", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Expansion Panels (Lesson: expansion.dart)
                  const Text("More Info", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ExpansionPanelList(
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        _expansionItems[index].isExpanded = isExpanded; // Flips boolean on click
                      });
                    },
                    children: _expansionItems.map<ExpansionPanel>((Item item) {
                      return ExpansionPanel(
                        backgroundColor: AppConstants.surfaceColor,
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return ListTile(
                            title: Text(item.header, style: const TextStyle(color: Colors.white)),
                          );
                        },
                        body: ListTile(
                          title: Text(item.body, style: TextStyle(color: Colors.grey.shade400)),
                        ),
                        isExpanded: item.isExpanded,
                        canTapOnHeader: true,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Booking Section
                  const Text("Book This Space", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Date Picker (Lesson: datePicker.dart)
                  TextField(
                    controller: _dateController,
                    readOnly: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppConstants.surfaceColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      labelText: 'Select Date',
                      labelStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.calendar_month, color: AppConstants.primaryColor),
                    ),
                    onTap: () {
                      _selectDate(context);
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Time Picker
                  TextField(
                    controller: _timeController,
                    readOnly: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppConstants.surfaceColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      labelText: 'Check-in Time',
                      labelStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.access_time, color: AppConstants.primaryColor),
                    ),
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                         builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: AppConstants.primaryColor,
                                onPrimary: Colors.black,
                                surface: AppConstants.surfaceColor,
                                onSurface: Colors.white,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _timeController.text = pickedTime.format(context);
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 100), // Spacing for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Bottom Bar (Reserve)
      bottomSheet: Container(
         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                   "\$${space.price.toStringAsFixed(0)}", 
                   style: const TextStyle(
                     color: Colors.white,
                     fontSize: 20, 
                     fontWeight: FontWeight.bold
                   ),
                 ),
                 const Text("/night", style: TextStyle(color: Colors.grey, fontSize: 14)),
               ],
             ),
             ElevatedButton(
               onPressed: _isAdmin ? null : () {
                  // Basic validation
                  DateTime checkInDate = DateTime.now();
                  if (_dateController.text.isNotEmpty) {
                    try {
                      checkInDate = DateTime.parse(_dateController.text);
                    } catch (e) {
                       // fallback
                    }
                  }
                  DateTime checkOutDate = checkInDate.add(const Duration(days: 1)); // Default 1 night for now

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PaymentInfoScreen(
                      price: space.price,
                      spaceId: space.id,
                      checkIn: checkInDate,
                      checkOut: checkOutDate,
                    )),
                  );
               },
               style: ElevatedButton.styleFrom(
                 backgroundColor: _isAdmin ? Colors.grey : AppConstants.primaryColor,
                 foregroundColor: Colors.black,
                 disabledBackgroundColor: Colors.grey.shade800,
                 disabledForegroundColor: Colors.white54,
                 padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
               ),
               child: Text(_isAdmin ? "Admin View Only" : "Reserve", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
             ),
           ],
         ),
      ),
    );
  }
}

// Simple Item class for ExpansionPanel
class Item {
  String header;
  String body;
  bool isExpanded;

  Item({
    required this.header,
    required this.body,
    this.isExpanded = false,
  });
}
