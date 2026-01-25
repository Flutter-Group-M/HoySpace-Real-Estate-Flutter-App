import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../services/chat_service.dart';
import 'conversation_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<dynamic> _conversations = [];
  List<dynamic> _filteredConversations = []; // Filtered list
  bool _isLoading = true;
  String? _error;
  Timer? _timer;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchConversations();
    // Poll for new conversations every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) _fetchConversations(isPolling: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Filter logic
  void _filterConversations(String query) {
    if (query.isEmpty) {
      setState(() => _filteredConversations = List.from(_conversations));
      return;
    }
    setState(() {
      _filteredConversations = _conversations.where((conv) {
        final name = conv['user']['name'].toString().toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  // Fetch conversations
  Future<void> _fetchConversations({bool isPolling = false}) async {
    try {
      final conversations = await ChatService().getConversations();
      if (mounted) {
        setState(() {
          _conversations = conversations;
          // Only update filtered list if not searching, or re-apply filter?
          // For simplicity, re-apply filter if search text exists
          if (_searchController.text.isEmpty) {
             _filteredConversations = List.from(conversations);
          } else {
             _filterConversations(_searchController.text);
          }
          
          if (!isPolling) _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // If polling fails, don't show error, just keep old data
          if (!isPolling) {
            _error = e.toString();
            _isLoading = false;
          }
        });
      }
    }
  }

  // Helper to refresh list (manual)
  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    await _fetchConversations();
  }

  ImageProvider _getImageProvider(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return const NetworkImage("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde");
    }
    if (imagePath.startsWith('http')) {
      return NetworkImage(imagePath);
    }
    try {
      return MemoryImage(base64Decode(imagePath));
    } catch (e) {
      return const NetworkImage("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text("Chat"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        // leading: BackButton(color: AppConstants.primaryColor), // Removed forced back button
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: AppConstants.primaryColor), onPressed: _refresh),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
           Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterConversations,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search Contacts...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _filterConversations("");
                      },
                    )
                  : null, 
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppConstants.primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppConstants.primaryColor),
                ),
                filled: true,
                fillColor: AppConstants.surfaceColor,
              ),
            ),
          ),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
              : _error != null
                  ? Center(child: Text("Error: $_error", style: const TextStyle(color: Colors.red)))
                  : _conversations.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
                              SizedBox(height: 16),
                              Text("No conversations yet", style: TextStyle(color: Colors.grey)),
                              SizedBox(height: 8),
                               Text(
                                "Visit a Space to contact the host!",
                                style: TextStyle(color: AppConstants.secondaryTextColor, fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      : _filteredConversations.isEmpty 
                          ? const Center(child: Text("No contacts found", style: TextStyle(color: Colors.grey)))
                          : ListView.separated(
                              itemCount: _filteredConversations.length,
                              separatorBuilder: (ctx, i) => const Divider(color: Colors.white12),
                              itemBuilder: (context, index) {
                                final conv = _filteredConversations[index];
                            final user = conv['user'];
                            final lastMessage = conv['lastMessage'];
                            // Format time simply for now
                            final time = DateTime.parse(conv['time']).toLocal().toString().substring(11, 16); 
                            final unread = conv['unreadCount'] ?? 0;

                            return _buildChatTile(
                              user['name'], 
                              lastMessage, 
                              time, 
                              unread,
                              user['image'], // Pass image path
                              () {
                                 Navigator.push(
                                   context, 
                                   MaterialPageRoute(builder: (_) => ConversationScreen(
                                     otherUserId: user['_id'].toString(), 
                                     otherUserName: user['name'],
                                     otherUserImage: user['image'],
                                   ))
                                 ).then((_) => _refresh()); // Refresh on return
                              }
                            );
                          },
                        ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(String name, String message, String time, int unreadCount, String? image, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey[800],
        backgroundImage: _getImageProvider(image),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
      subtitle: Text(message, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppConstants.secondaryTextColor)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(time, style: const TextStyle(fontSize: 12, color: AppConstants.secondaryTextColor)),
          if (unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppConstants.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
