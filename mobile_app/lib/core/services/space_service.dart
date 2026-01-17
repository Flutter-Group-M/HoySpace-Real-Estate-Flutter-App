import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../models/space_model.dart';

class SpaceService {
  Future<List<Space>> getSpaces({String? query, String? location, String? category}) async {
    try {
      String url = '${AppConstants.baseUrl}/spaces?';
      if (query != null && query.isNotEmpty) url += 'search=$query&';
      if (location != null && location.isNotEmpty) url += 'location=$location&';
      if (category != null && category.isNotEmpty) url += 'category=$category&';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Space.fromJson(json)).toList();
      } else {
        print("Get Spaces Failed: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Get Spaces Error: $e");
      return [];
    }
  }
}
