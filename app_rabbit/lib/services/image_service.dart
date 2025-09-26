import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/image_model.dart';

class ImageService {
  // Using Pixabay API - free and reliable image API
  static const String _baseUrl = 'https://pixabay.com/api';
  
  static String get _apiKey {
    final apiKey = dotenv.env['PIXABAY_API'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('PIXABAY_API key not found in environment variables. Please add it to your .env file.');
    }
    return apiKey;
  }
  
  static Future<List<ImageModel>> searchImages(String query, {int page = 1, int perPage = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/?key=$_apiKey&q=${Uri.encodeComponent(query)}&page=$page&per_page=$perPage&image_type=photo&safesearch=true'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['hits'] ?? [];
        
        return results.map((json) => ImageModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load images: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching images: $e');
    }
  }
  
  static Future<List<ImageModel>> getRandomImages({int count = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/?key=$_apiKey&q=nature&per_page=$count&image_type=photo&safesearch=true&order=popular'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['hits'] ?? [];
        return results.map((json) => ImageModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load random images: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching random images: $e');
    }
  }
}
