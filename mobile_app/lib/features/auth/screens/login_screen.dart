import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../core/constants.dart';
import '../../home/screens/main_wrapper.dart';
import '../services/auth_service.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Dark background matching design
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Logo
              Column(
                children: [
                  Text(
                    'Hoy Space',
                    style: TextStyle(
                      fontFamily: 'Serif', // Using a serif font to match design slightly better
                      color: const Color(0xFFE8DCC4), // Light beige/white
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Icon(Icons.home, color: AppConstants.primaryColor, size: 40), // Using Home icon as placeholder for image logo, or implement image if available
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
              
              const SizedBox(height: 40),
              
              const Text(
                'Log In',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE8DCC4), // Beige/White
                  fontFamily: 'Serif',
                ),
              ),
               
              const SizedBox(height: 10),
              
              Text(
                'Enter to a Hoy Space Account to\nstart discover a bunch of Live\nSpaces waiting for you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),
              
              // Email Field
              Align(alignment: Alignment.centerLeft, child: Text("Your Email", style: TextStyle(color: Color(0xFFE8DCC4), fontSize: 16))),
              const SizedBox(height: 8),
              _buildTextField(_emailController, "example@gmail.com", false),

              const SizedBox(height: 20),

              // Password Field
              Align(alignment: Alignment.centerLeft, child: Text("Your Password", style: TextStyle(color: Color(0xFFE8DCC4), fontSize: 16))),
              const SizedBox(height: 8),
              _buildTextField(_passwordController, "123@!#", true),

              const SizedBox(height: 20),
              
              Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                         Get.to(() => const ForgotPasswordScreen());
                    },
                    child: Text('Forget Password', style: TextStyle(color: Colors.grey, fontSize: 16))
                  ),
               ),

              const SizedBox(height: 30),
              
              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
              _buildSocialButton("Log In With Google", FontAwesomeIcons.google, Colors.red),
              const SizedBox(height: 15),
              _buildSocialButton("Log In With Apple", FontAwesomeIcons.apple, Colors.white),

              const SizedBox(height: 30),
              
              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: () {
                       Get.to(() => const SignupScreen());
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, bool isPassword) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade600),
        filled: true,
        fillColor: const Color(0xFF2C2C2C), // Slightly lighter than background
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
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
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

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all fields", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final authService = AuthService();
    final error = await authService.login(_emailController.text.trim(), _passwordController.text);

    if (error == null && mounted) {
       Get.offAll(() => const MainWrapper());
    } else if (mounted) {
       Get.snackbar("Error", error ?? "Login Failed", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
