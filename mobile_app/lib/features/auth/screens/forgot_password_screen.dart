import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../services/auth_service.dart';
import 'new_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter your email")));
      return;
    }

    setState(() => _isLoading = true);
    final success = await _authService.forgotPassword(email);
    setState(() => _isLoading = false);

    if (success) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VerificationScreen(email: email)),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to send code. Check email or try again.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Reset Password", 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Enter your email address and we will send you a code to reset your password.",
              style: TextStyle(color: AppConstants.secondaryTextColor),
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppConstants.surfaceColor,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text('Send Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VerificationScreen extends StatefulWidget {
  final String email;
  const VerificationScreen({super.key, required this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _verify() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
       // Assuming 6 digits based on backend generation
       // But user said "enter the realcode".
       // Backend generates 6 digits.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter the 6-digit code")));
      return;
    }

    setState(() => _isLoading = true);
    final success = await _authService.verifyOTP(widget.email, otp);
    setState(() => _isLoading = false);

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Verification Successful!")));
      
      // Navigate to New Password Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewPasswordScreen(
            email: widget.email, 
            otp: otp
          )
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Code")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
             const Text(
              "Verification Code", 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "We have sent the code verification to ${widget.email}",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppConstants.secondaryTextColor),
            ),
             const SizedBox(height: 30),
             
             // Simple TextField for Code (Replacing fancy boxes for functionality first)
             TextFormField(
               controller: _otpController,
               textAlign: TextAlign.center,
               keyboardType: TextInputType.number,
               maxLength: 6,
               style: const TextStyle(fontSize: 24, letterSpacing: 10),
               decoration: InputDecoration(
                 hintText: "******",
                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                 filled: true,
                 fillColor: AppConstants.surfaceColor,
                 counterText: ""
               ),
             ),
             
             const SizedBox(height: 40),
             SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text('Verify', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
