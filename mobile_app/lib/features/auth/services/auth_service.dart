import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants.dart';

class AuthService {
  // Login
  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        
        // Save Token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('userId', data['_id'].toString());
        await prefs.setString('userName', data['name']);
        await prefs.setString('email', email);
        if (data['phone'] != null) await prefs.setString('phone', data['phone']);
        await prefs.setString('role', data['role']);
        await prefs.setString('image', data['image'] ?? "");
        
        return null; // Success
      } else {
        print("Login Failed: ${response.statusCode}");
        print("Response Body: ${response.body}");
        final data = jsonDecode(response.body);
        return data['message'] ?? "Login Failed: ${response.statusCode}";
      }
    } catch (e) {
      print("Login Error: $e");
      return "Network Error: $e";
    }
  }

  // Signup
  Future<String?> signup(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final token = data['token'];
        
        // Save Token and User Data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('userId', data['_id'].toString());
        await prefs.setString('userName', data['name']);
        await prefs.setString('email', email);
        if (data['phone'] != null) await prefs.setString('phone', data['phone']);
        await prefs.setString('role', data['role']);
        await prefs.setString('image', data['image'] ?? "");
        
        return null; // Success
      } else {
        print("Signup Failed: ${response.statusCode}");
        return data['message'] ?? "Signup Failed";
      }
    } catch (e) {
      print("Signup Error: $e");
      return "Network Error: $e";
    }
  }

  // Forgot Password (Send OTP)
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Forgot Password Failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Forgot Password Error: $e");
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Verify OTP Failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Verify OTP Error: $e");
      return false;
    }
  }

  // Reset Password
  Future<bool> resetPassword(String email, String otp, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email, 
          'otp': otp,
          'newPassword': newPassword
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Reset Password Failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Reset Password Error: $e");
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  // Update Profile
  Future<bool> updateProfile(String name, String email, String phone, String? image) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'image': image,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Update local data
        await prefs.setString('userName', data['name']);
        await prefs.setString('email', data['email']);
        if (data['phone'] != null) await prefs.setString('phone', data['phone']);
        await prefs.setString('image', data['image'] ?? "");
        return true;
      } else {
        print("Update Failed: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      print("Update Error: $e");
      return false;
    }
  }

  // Update Password
  Future<bool> updatePassword(String newPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Update Password Failed: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      print("Update Password Error: $e");
      return false;
    }
  }

  // Get User Stats
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/users/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Get Stats Failed: ${response.statusCode} ${response.body}");
        return {'bookings': 0, 'reviews': 0, 'saved': 0};
      }
    } catch (e) {
      print("Get Stats Error: $e");
      return {'bookings': 0, 'reviews': 0, 'saved': 0};
    }
  }

  // Check if Admin
  Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role') == 'admin';
  }
}
