import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../core/constants.dart';
import '../../home/screens/main_wrapper.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController(); 
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
         child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               // Back Button
               Align(
                 alignment: Alignment.topLeft,
                 child: IconButton(
                   icon: const Icon(Icons.arrow_back, color: Colors.white),
                   onPressed: () => Get.back(),
                 ),
               ),
               
               const SizedBox(height: 10),
               // Logo
              Column(
                children: [
                  Text(
                    'Hoy Space',
                    style: TextStyle(
                      fontFamily: 'Serif',
                      color: const Color(0xFFE8DCC4), 
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                   const SizedBox(height: 10),
                   Icon(Icons.home, color: AppConstants.primaryColor, size: 40),
                   Text(
                    'HoySpace',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),

              const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE8DCC4),
                  fontFamily: 'Serif',
                ),
              ),
              
              const SizedBox(height: 10),
               Text(
                'Create a HoySpace Account to\nstart discover a bunch of Live\nSpaces waiting for you.',
                 textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
               const SizedBox(height: 30),
               
               // Name Field
              Align(alignment: Alignment.centerLeft, child: Text("Full Name", style: TextStyle(color: Color(0xFFE8DCC4), fontSize: 16))),
               const SizedBox(height: 8),
              _buildTextField(_nameController, "John Doe", false),
               const SizedBox(height: 20),

               // Email Field
              Align(alignment: Alignment.centerLeft, child: Text("Your Email", style: TextStyle(color: Color(0xFFE8DCC4), fontSize: 16))),
               const SizedBox(height: 8),
              _buildTextField(_emailController, "example@gmail.com", false),
               const SizedBox(height: 20),

               // Password Field
              Align(alignment: Alignment.centerLeft, child: Text("Your Password", style: TextStyle(color: Color(0xFFE8DCC4), fontSize: 16))),
               const SizedBox(height: 8),
              _buildTextField(_passwordController, "123@!#", true, isConfirm: false),
               const SizedBox(height: 20),

                // Re-Enter Password Field
              Align(alignment: Alignment.centerLeft, child: Text("Re-Enter Password", style: TextStyle(color: Color(0xFFE8DCC4), fontSize: 16))),
               const SizedBox(height: 8),
              _buildTextField(_confirmPasswordController, "123@!#", true, isConfirm: true),
              
              const SizedBox(height: 30),

               // Already Has Account Link
               Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? ", style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Text(
                      'Log In',
                      style: TextStyle(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
               // Signup Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),

              const SizedBox(height: 30),
              
               // Divider
               Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade700)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text("Or with", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade700)),
                ],
              ),
               const SizedBox(height: 30),

               // Social Buttons
              _buildSocialButton("Sign In With Google", FontAwesomeIcons.google, Colors.red),
              const SizedBox(height: 15),
              _buildSocialButton("Sign In With Apple", FontAwesomeIcons.apple, Colors.white),

               const SizedBox(height: 30),
            ],
          ),
         ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, bool isPassword, {bool isConfirm = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && (isConfirm ? !_isConfirmPasswordVisible : !_isPasswordVisible),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade600),
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppConstants.primaryColor),
        ),
         enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppConstants.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        suffixIcon: isPassword ? IconButton(
            icon: Icon(
              (isConfirm ? _isConfirmPasswordVisible : _isPasswordVisible) ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                if(isConfirm) {
                   _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                } else {
                   _isPasswordVisible = !_isPasswordVisible;
                }
              });
            },
          ) : null,
      ),
    );
  }

   Widget _buildSocialButton(String text, IconData icon, Color iconColor) {
     return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () {
           // Placeholder for social login
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Social Login coming soon!")));
        },
        icon: Icon(icon, color: iconColor, size: 20),
        label: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppConstants.primaryColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

   Future<void> _signup() async {
     if (_nameController.text.isEmpty ||_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all fields", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      Get.snackbar("Error", "Passwords do not match", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final authService = AuthService();
    final error = await authService.signup(_nameController.text, _emailController.text, _passwordController.text);

    if (error == null && mounted) {
       Get.offAll(() => const MainWrapper());
    } else if (mounted) {
       Get.snackbar("Error", error ?? "Signup Failed", backgroundColor: Colors.red, colorText: Colors.white);
    }
   }
}
