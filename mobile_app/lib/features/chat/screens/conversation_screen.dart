import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants.dart';
import '../services/chat_service.dart';

class ConversationScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String? otherUserImage;

  const ConversationScreen({
    super.key, 
    required this.otherUserId, 
    required this.otherUserName,
    this.otherUserImage
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _messages = [];
  String? _currentUserId;
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _fetchMessages();
    // Poll for new messages every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) _fetchMessages(isPolling: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('userId');
    });
  }

  Future<void> _fetchMessages({bool isPolling = false}) async {
    final messages = await ChatService().getMessages(widget.otherUserId);
    if (mounted) {
      // Check if messages changed before setting state to avoid visual glitches or scroll jumps during polling
      // Simple length check or last message check could be optimized, but full replace is safer for sync
      if (_messages.length != messages.length || !isPolling) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        if (!isPolling) _scrollToBottom(); // Scroll only on initial load or manual send
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent, 
          duration: const Duration(milliseconds: 300), 
          curve: Curves.easeOut
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final content = _messageController.text;
    _messageController.clear(); // Optimistically clear

    // Optimistically add to list
    final tempMessage = {
      'content': content,
      'sender': {'_id': _currentUserId},
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    setState(() {
      _messages.add(tempMessage);
    });
    _scrollToBottom();

    final success = await ChatService().sendMessage(widget.otherUserId, content);
    
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to send")));
      }
      _fetchMessages(); 
    } else {
      _fetchMessages(); 
    }
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
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: _getImageProvider(widget.otherUserImage),
              radius: 16,
            ),
            const SizedBox(width: 10),
            Text(widget.otherUserName, style: const TextStyle(fontSize: 16)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: BackButton(color: AppConstants.primaryColor),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg['sender']['_id'] == _currentUserId;
                      return _buildMessageBubble(msg['content'], isMe);
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
             CircleAvatar(
              radius: 12,
              backgroundImage: _getImageProvider(widget.otherUserImage),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppConstants.primaryColor : AppConstants.surfaceColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(0),
                  bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.black : Colors.white, 
                  fontWeight: isMe ? FontWeight.bold : FontWeight.normal
                ),
              ),
            ),
          ),
          // Add spacing if it's me to balance the avatar space visually or keep right aligned
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppConstants.surfaceColor,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: AppConstants.primaryColor),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
