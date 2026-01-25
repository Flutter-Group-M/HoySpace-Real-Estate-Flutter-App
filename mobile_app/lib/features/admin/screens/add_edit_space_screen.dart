import 'dart:convert';

import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants.dart';
import '../../../core/models/space_model.dart';

class AddEditSpaceScreen extends StatefulWidget {
  final Space? space;
  const AddEditSpaceScreen({super.key, this.space});

  @override
  State<AddEditSpaceScreen> createState() => _AddEditSpaceScreenState();
}

class _AddEditSpaceScreenState extends State<AddEditSpaceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _locationController;
  
  List<String> _images = []; // Base64 strings or URLs
  bool _isLoading = false;

  String _category = 'Hotel';
  final List<String> _categories = ["Hotel", "Apartment", "Guest House", "Beachfront", "Cabin", "Trending", "Luxury", "Mansions", "Islands", "Camping"];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.space?.title ?? '');
    _descController = TextEditingController(text: widget.space?.description ?? '');
    _priceController = TextEditingController(text: widget.space?.price.toString() ?? '');
    _locationController = TextEditingController(text: widget.space?.location ?? '');
    _images = widget.space?.images ?? [];
    _category = widget.space?.category ?? 'Hotel';
    
    // Ensure the initial category is valid
    if (!_categories.contains(_category)) {
      _categories.add(_category);
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        final String base64Image = base64Encode(bytes);
        setState(() {
          _images.add(base64Image); 
        });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image added!")));
      }
    } catch (e) {
       print("Error: $e");
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  Future<void> _saveSpace() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final body = jsonEncode({
      'title': _titleController.text,
      'description': _descController.text,
      'price': double.tryParse(_priceController.text) ?? 0,
      'location': _locationController.text,
      'images': _images,
      'amenities': ['Wifi', 'Parking'], 
      'category': _category,
    });

    try {
      http.Response response;
      if (widget.space == null) {
        // Create
        response = await http.post(
          Uri.parse('${AppConstants.baseUrl}/spaces'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: body,
        );
      } else {
        // Update
        response = await http.put(
          Uri.parse('${AppConstants.baseUrl}/spaces/${widget.space!.id}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: body,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) Navigator.pop(context);
      } else {
        print("Save Space Error: ${response.statusCode} - ${response.body}");
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
             content: Text("Failed to save: ${response.statusCode} ${response.body}"),
             backgroundColor: Colors.red,
           ));
        }
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error saving space")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.space != null;
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Space' : 'Add Space'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("Title", _titleController),
              const SizedBox(height: 16),
              _buildTextField("Description", _descController, maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField("Price (per night)", _priceController, isNumber: true),
              const SizedBox(height: 16),
              _buildTextField("Location", _locationController),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _category,
                dropdownColor: AppConstants.surfaceColor,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: AppConstants.surfaceColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade800)
                  ),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 24),
              
              const Text("Images", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _images.length) {
                      return GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: AppConstants.surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: const Icon(Icons.add_a_photo, color: Colors.white),
                        ),
                      );
                    }
                    
                    final img = _images[index];
                    return Stack(
                      children: [
                        Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: _getImageProvider(img),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 15,
                          child: GestureDetector(
                            onTap: () => setState(() => _images.removeAt(index)),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveSpace,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.black,
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.black) 
                      : const Text("Save Space", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider _getImageProvider(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const NetworkImage("https://images.unsplash.com/photo-1566073771259-6a8506099945");
    }
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      return NetworkImage(imageUrl);
    }
    try {
      return MemoryImage(base64Decode(imageUrl));
    } catch (e) {
      print("Error decoding base64 image: $e");
      return const NetworkImage("https://images.unsplash.com/photo-1566073771259-6a8506099945");
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: AppConstants.surfaceColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: BorderSide(color: Colors.grey.shade800)
        ),
      ),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }
}
