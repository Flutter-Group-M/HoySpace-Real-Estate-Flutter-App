import 'package:flutter/material.dart';
import '../../../core/constants.dart';
<<<<<<< HEAD
import '../../home/screens/home_screen.dart';
=======
import '../../home/screens/main_wrapper.dart';
>>>>>>> feature/profile

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, 
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png', 
              height: 100,
              width: 100,
            ),
             const SizedBox(height: 16),
             const Text(
              "HoySpace",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            const Text(
              "Successfully",
              style: TextStyle(
                color: Color(0xFFE0CFA0), 
                fontSize: 24,
                fontFamily: 'Serif',
                fontWeight: FontWeight.bold,
              ),
            ),
             const Text(
              "Booked a Space!",
              style: TextStyle(
                color: Color(0xFFE0CFA0), 
                fontSize: 24,
                fontFamily: 'Serif',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Thanks for putting your trust on us,\nwe hope you enjoyed it!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            
            const SizedBox(height: 60),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                     Navigator.of(context).pushAndRemoveUntil(
<<<<<<< HEAD
                       MaterialPageRoute(builder: (context) => const HomeScreen()), 
=======
                       MaterialPageRoute(builder: (context) => const MainWrapper()), 
>>>>>>> feature/profile
                       (route) => false
                     );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppConstants.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Back", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
