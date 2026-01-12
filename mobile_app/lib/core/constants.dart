import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppConstants {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS simulator and Web
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    return 'http://10.0.2.2:5000/api';
  }
  
  // Colors inferred from "HoySpace" branding (likely Gold/Black/Dark Theme based on premium description)
  static const Color primaryColor = Color(0xFFFFD700); // Gold
  static const Color backgroundColor = Color(0xFF121212); // Dark Background
  static const Color surfaceColor = Color(0xFF1E1E1E); // Card Color
  static const Color textColor = Colors.white;
  static const Color secondaryTextColor = Colors.grey;
}
