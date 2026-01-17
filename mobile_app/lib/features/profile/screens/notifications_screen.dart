import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/services/notification_service.dart';
// import 'package:timeago/timeago.dart' as timeago; // Optional: Add timeago package later for "2m ago"

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<NotificationItem>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = NotificationService().getNotifications();
  }

  Future<void> _refresh() async {
    setState(() {
      _notificationsFuture = NotificationService().getNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Notifications", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: const BackButton(color: AppConstants.primaryColor),
      ),
      body: FutureBuilder<List<NotificationItem>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No notifications yet", style: TextStyle(color: Colors.grey)));
          }

          final notifications = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppConstants.primaryColor,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.grey),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: notification.isRead ? Colors.transparent : AppConstants.surfaceColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppConstants.primaryColor.withOpacity(0.5)),
                    ),
                    child: Icon(
                      Icons.notifications, 
                      color: notification.isRead ? Colors.grey : AppConstants.primaryColor, 
                      size: 20
                    ),
                  ),
                  title: Text(
                    notification.title, 
                    style: TextStyle(
                      color: Colors.white, 
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold
                    )
                  ),
                  subtitle: Text(
                    notification.message, 
                    style: TextStyle(color: Colors.grey[400])
                  ),
                  trailing: Text(
                    _formatDate(notification.createdAt), // Simple formatter
                    style: const TextStyle(color: Colors.grey, fontSize: 12)
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) {
        return "${diff.inMinutes}m ago";
      } else if (diff.inHours < 24) {
        return "${diff.inHours}h ago";
      } else {
        return "${diff.inDays}d ago";
      }
    } catch (e) {
      return "Just now";
    }
  }
}
