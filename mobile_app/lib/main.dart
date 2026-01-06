import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:device_preview/device_preview.dart';
import 'features/profile/screens/profile_screen.dart';
import 'core/constants.dart';
import 'features/common/screens/splash_screen.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true, // Forced enabled for testing. Change to !kReleaseMode for production.
      builder: (context) => const HoySpaceApp(),
    ),
  );
}

class HoySpaceApp extends StatelessWidget {
  const HoySpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'HoySpace',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        colorScheme: const ColorScheme.dark(
          primary: AppConstants.primaryColor,
          surface: AppConstants.surfaceColor,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: AppConstants.textColor,
          displayColor: AppConstants.textColor,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(), // Keep splash as initial
        '/profile': (context) => const ProfileScreen(),

      },
    );
  }
}
