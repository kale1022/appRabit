import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static GenerativeModel? _model;
  
  // Using Gemini 2.5 Flash Image Preview - FREE model for multimodal processing
  // This model is specifically designed for image analysis and is free to use
  static const String _freeModel = 'gemini-2.5-flash-image-preview';
  
  static String get _apiKey {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in environment variables. Please add it to your .env file.');
    }
    return apiKey;
  }

  static Future<void> _initializeModel() async {
    _model ??= GenerativeModel(
      model: _freeModel, // Using FREE model - no charges
      apiKey: _apiKey,
    );
  }

  /// Analyzes an image and generates a search prompt for finding similar images
  static Future<String> analyzeImageAndGeneratePrompt(File imageFile) async {
    try {
      await _initializeModel();
      
      final imageBytes = await imageFile.readAsBytes();
      final prompt = '''
Analyze this image and create a detailed text description that would be perfect for finding similar images through an image search API. 

Focus on:
- Main subjects and objects
- Colors and visual style
- Composition and mood
- Environment and setting
- Art style if applicable
- Lighting and atmosphere

Return only a concise, search-friendly description (2-4 keywords or short phrases) that captures the essence of this image for finding similar photos. Make it specific enough to find relevant results but broad enough to find variations.

Examples of good descriptions:
- "sunset over ocean waves"
- "modern architecture glass building"
- "cozy coffee shop interior"
- "mountain landscape with trees"
- "abstract colorful geometric shapes"
- "vintage car on country road"

Your response:''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', Uint8List.fromList(imageBytes)),
        ])
      ];
      
      final response = await _model!.generateContent(content);
      
      final generatedText = response.text?.trim() ?? '';
      
      if (generatedText.isEmpty) {
        throw Exception('No description generated from image');
      }
      
      return generatedText;
    } catch (e) {
      throw Exception('Failed to analyze image: $e');
    }
  }

  /// Generates alternative search terms for the same image
  static Future<List<String>> generateAlternativePrompts(File imageFile) async {
    try {
      await _initializeModel();
      
      final imageBytes = await imageFile.readAsBytes();
      final prompt = '''
Analyze this image and generate 3 different search descriptions that would find similar images. Each should be 2-4 words and focus on different aspects:

1. Focus on the main subject/object
2. Focus on the style/mood/atmosphere  
3. Focus on the colors/composition

Return only the 3 descriptions, one per line, without numbers or bullets.''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', Uint8List.fromList(imageBytes)),
        ])
      ];
      
      final response = await _model!.generateContent(content);
      
      final generatedText = response.text?.trim() ?? '';
      final prompts = generatedText.split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .take(3)
          .toList();
      
      if (prompts.isEmpty) {
        throw Exception('No alternative prompts generated');
      }
      
      return prompts;
    } catch (e) {
      throw Exception('Failed to generate alternative prompts: $e');
    }
  }
}