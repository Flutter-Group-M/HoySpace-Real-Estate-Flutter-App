import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants.dart';
import '../../../core/models/space_model.dart';
import 'add_edit_space_screen.dart';

class SpaceManagementScreen extends StatefulWidget {
  const SpaceManagementScreen({super.key});

  @override
  State<SpaceManagementScreen> createState() => _SpaceManagementScreenState();
}

class _SpaceManagementScreenState extends State<SpaceManagementScreen> {
  List<Space> _spaces = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSpaces();
  }

  Future<void> _fetchSpaces() async {
    try {
      final response = await http.get(Uri.parse('${AppConstants.baseUrl}/spaces'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _spaces = data.map((json) => Space.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSpace(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Space"),
        content: const Text("Are you sure you want to delete this listing?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      await http.delete(
        Uri.parse('${AppConstants.baseUrl}/spaces/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      _fetchSpaces();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Manage Spaces'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConstants.primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditSpaceScreen()),
          ).then((_) => _fetchSpaces());
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _spaces.length,
              itemBuilder: (context, index) {
                final space = _spaces[index];
                final hasImage = space.images.isNotEmpty;
                final image = hasImage ? space.images[0] : null;

                return Card(
                  color: AppConstants.surfaceColor,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      // Image Header
                      SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: image != null
                           ? (image.startsWith('http')
                              ? Image.network(image, fit: BoxFit.cover)
                              : Image.memory(base64Decode(image), fit: BoxFit.cover))
                           : Container(color: Colors.grey, child: const Icon(Icons.image_not_supported)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    space.title, 
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${space.price} / night', 
                                    style: const TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold)
                                  ),
                                  Text(
                                    space.location, 
                                    style: const TextStyle(color: Colors.grey, fontSize: 12)
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                              onPressed: () {
                                 Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => AddEditSpaceScreen(space: space)),
                                ).then((_) => _fetchSpaces());
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _deleteSpace(space.id),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
