import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants.dart';
import '../../auth/services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(); 
  final _phoneController = TextEditingController();
  String? _currentImageUrl;
  
  // Using bytes for image preview to avoid dart:io File dependence
  Uint8List? _pickedImageBytes; 

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

    Future<void> _loadCurrentData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('userName') ?? "Sharmake Hassan";
      _emailController.text = prefs.getString('email') ?? ""; 
      _phoneController.text = prefs.getString('phone') ?? ""; 
      _currentImageUrl = prefs.getString('image');
    });
  }

  Future<void> _pickImage() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Attempting to open gallery..."), duration: Duration(milliseconds: 500)));
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 25, // Aggressive compression (was 50)
        maxWidth: 600,    // Smaller dimensions (was 800)
        maxHeight: 600,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _pickedImageBytes = bytes;
        });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image selected!")));
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No image selected")));
      }
    } catch (e) {
      print("Error picking image: $e");
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: BackButton(color: AppConstants.primaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
             Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppConstants.primaryColor, width: 2),
                    image: _pickedImageBytes != null 
                        ? DecorationImage(
                            image: MemoryImage(_pickedImageBytes!), 
                            fit: BoxFit.cover
                          )
                        : DecorationImage(
                            image: _getImageProvider(_currentImageUrl), 
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 36, 
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppConstants.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, size: 18, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            _buildTextField("Name", _nameController),
            const SizedBox(height: 20),
            _buildTextField("Email", _emailController),
            const SizedBox(height: 20),
            _buildTextField("Phone Number", _phoneController),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                   String? imageBase64;
                   if (_pickedImageBytes != null) {
                     imageBase64 = base64Encode(_pickedImageBytes!);
                   }

                   final success = await AuthService().updateProfile(
                     _nameController.text,
                     _emailController.text,
                     _phoneController.text,
                     imageBase64,
                   );

                   if (success && context.mounted) {
                     Navigator.pop(context);
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated")));
                   } else if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Update Failed"), backgroundColor: Colors.red));
                   }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Save Changes", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider _getImageProvider(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const NetworkImage("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde");
    }
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      return NetworkImage(imageUrl);
    }
    try {
      return MemoryImage(base64Decode(imageUrl));
    } catch (e) {
      print("Error decoding base64 image: $e");
      return const NetworkImage("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde");
    }
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppConstants.surfaceColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade800)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppConstants.primaryColor)),
          ),
        ),
      ],
    );
  }
}
