import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/signup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "image": "https://images.unsplash.com/photo-1586023492125-27b2c045efd7",
      "title": "Live Space\nFor You.",
      "desc": "Discover Live spaces that suites you the best. Stay with ease, live relaxed, and search with Hoy."
    },
    {
      "image": "https://images.unsplash.com/photo-1554995207-c18c203602cb",
      "title": "Find Your\nComfort.",
      "desc": "Experience the best hospitality and comfort with our premium selection of spaces."
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                   // Background Image
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(_onboardingData[index]["image"]!),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  
                  // Text Content (Positioned relative to image or just fixed at bottom)
                  // We'll handle text in the main stack's bottom layer to keep buttons fixed, 
                  // or we can make text slide too. Let's make text slide.
                ],
              );
            },
          ),

          // Content Layer (Text + Buttons)
          // To make text slide, we should probably put text inside PageView.
          // But buttons should stay fixed? Or buttons slide?
          // Design 2 shows buttons and dots.
          // Let's put text inside PageView.
          
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   // Logo
                  const Column(
                    children: [
                       Icon(Icons.home_filled, color: AppConstants.primaryColor, size: 40),
                       Text("Hoy Space", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Dynamic Text based on current page (Simpler than sliding text for now, or use PageView for text too)
                  Text(
                    _onboardingData[_currentPage]["title"]!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: const Color(0xFFE0CFA0),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Serif',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _onboardingData[_currentPage]["desc"]!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppConstants.secondaryTextColor, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  
                  // Dots Indicator
                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length, 
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? Colors.white : Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                         Get.to(() => const LoginScreen());
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppConstants.primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                          Get.to(() => const SignupScreen());
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppConstants.primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Sign Up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}