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
      title: 'VisualFlow - AI Image Discovery',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Indigo as primary
          brightness: Brightness.light,
        ),
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
  final GlobalKey<DebouncedSearchFieldState> _searchFieldKey = GlobalKey<DebouncedSearchFieldState>();

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
        backgroundColor: const Color(0xFF6366F1), // Purple to match app theme
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6366F1).withValues(alpha: 0.08),
              const Color(0xFF8B5CF6).withValues(alpha: 0.05),
              colorScheme.surface,
              const Color(0xFFEC4899).withValues(alpha: 0.03),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar with Enhanced Branding
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    // Enhanced Logo with 3D effect
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF6366F1), // Indigo
                            const Color(0xFF8B5CF6), // Purple
                            const Color(0xFFEC4899), // Pink
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: const Color(0xFFEC4899).withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // App Name with Gradient Text
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF6366F1),
                                const Color(0xFF8B5CF6),
                                const Color(0xFFEC4899),
                              ],
                            ).createShader(bounds),
                            child: Text(
                              'VisualFlow',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'AI-Powered Image Discovery',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
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
              
              // Search Field with Debouncing
              DebouncedSearchField(
                key: _searchFieldKey,
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
