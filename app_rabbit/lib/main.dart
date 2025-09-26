import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'models/image_model.dart';
import 'services/image_service.dart';
import 'services/gemini_service.dart';
import 'widgets/debounced_search_field.dart';
import 'widgets/image_grid.dart';
import 'widgets/image_upload_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Search App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ImageSearchScreen(),
    );
  }
}

class ImageSearchScreen extends StatefulWidget {
  const ImageSearchScreen({super.key});

  @override
  State<ImageSearchScreen> createState() => _ImageSearchScreenState();
}

class _ImageSearchScreenState extends State<ImageSearchScreen> {
  List<ImageModel> _images = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _currentQuery = '';
  bool _isAnalyzingImage = false;

  @override
  void initState() {
    super.initState();
    _loadRandomImages();
  }

  Future<void> _loadRandomImages() async {
    setState(() {
      _isLoading = true;
      _images.clear();
      _currentPage = 1;
      _hasMore = true;
    });

    try {
      final images = await ImageService.getRandomImages();
      setState(() {
        _images = images;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load images: $e');
    }
  }

  Future<void> _searchImages(String query) async {
    if (query.trim().isEmpty) {
      _loadRandomImages();
      return;
    }

    setState(() {
      _isLoading = true;
      _images.clear();
      _currentPage = 1;
      _hasMore = true;
      _currentQuery = query;
    });

    try {
      final images = await ImageService.searchImages(query, page: _currentPage);
      setState(() {
        _images = images;
        _isLoading = false;
        _hasMore = images.length >= 20;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to search images: $e');
    }
  }

  Future<void> _loadMoreImages() async {
    if (!_hasMore || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final nextPage = _currentPage + 1;
      List<ImageModel> newImages;
      
      if (_currentQuery.isEmpty) {
        newImages = await ImageService.getRandomImages(count: 20);
      } else {
        newImages = await ImageService.searchImages(_currentQuery, page: nextPage);
      }

      setState(() {
        _images.addAll(newImages);
        _currentPage = nextPage;
        _isLoading = false;
        _hasMore = newImages.length >= 20;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load more images: $e');
    }
  }

  Future<void> _handleImageUpload(File imageFile) async {
    setState(() {
      _isAnalyzingImage = true;
    });

    try {
      // Analyze image with Gemini API
      final searchPrompt = await GeminiService.analyzeImageAndGeneratePrompt(imageFile);
      
      // Search for similar images using the generated prompt
      await _searchImages(searchPrompt);
      
      _showSuccessSnackBar('Found similar images using AI analysis!');
    } catch (e) {
      _showErrorSnackBar('Failed to analyze image: $e');
    } finally {
      setState(() {
        _isAnalyzingImage = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withValues(alpha: 0.05),
              colorScheme.surface,
              colorScheme.secondary.withValues(alpha: 0.02),
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.photo_library_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Image Explorer',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Discover amazing visuals',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                        onPressed: _loadRandomImages,
                        tooltip: 'Refresh',
                      ),
                    ),
                  ],
                ),
              ),
              
              // Upload Widget
              ImageUploadWidget(
                onImageSelected: _handleImageUpload,
                onSearchPromptGenerated: _searchImages,
                isLoading: _isAnalyzingImage,
              ),
              
              // Search Field
              DebouncedSearchField(
                hintText: _getFunHintText(),
                onChanged: _searchImages,
              ),
              
              // Image Grid
              Expanded(
                child: _isLoading && _images.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.image_search_rounded,
                                size: 48,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Searching for amazing images...',
                              style: TextStyle(
                                fontSize: 16,
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ImageGrid(
                        images: _images,
                        onLoadMore: _loadMoreImages,
                        isLoading: _isLoading,
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _images.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _loadRandomImages,
              icon: const Icon(Icons.shuffle_rounded),
              label: const Text('Shuffle'),
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 4,
            )
          : null,
    );
  }

  String _getFunHintText() {
    final hints = [
      '🔍 Try "sunset" or "cats"...',
      '🌟 Search for "nature" or "food"...',
      '🎨 Look for "art" or "travel"...',
      '🚀 Find "space" or "ocean"...',
      '🏔️ Try "mountains" or "city"...',
      '🌸 Search "flowers" or "animals"...',
    ];
    return hints[DateTime.now().millisecond % hints.length];
  }
}
