import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants.dart';

class ChatService {
  Future<List<dynamic>> getConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/chat/conversations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Get Conversations Failed: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Get Conversations Error: $e");
    }
  }

  Future<List<dynamic>> getMessages(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/chat/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Get Messages Failed: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Get Messages Error: $e");
      return [];
    }
  }

  Future<bool> sendMessage(String receiverId, String content) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'receiverId': receiverId,
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Send Message Failed: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Send Message Error: $e");
      return false;
    }
  }
}
