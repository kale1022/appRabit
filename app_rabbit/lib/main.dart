import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'models/image_model.dart';
import 'services/image_service.dart';
import 'widgets/debounced_search_field.dart';
import 'widgets/image_grid.dart';

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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Image Search',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          DebouncedSearchField(
            hintText: 'Search for images...',
            onChanged: _searchImages,
          ),
          Expanded(
            child: _isLoading && _images.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ImageGrid(
                    images: _images,
                    onLoadMore: _loadMoreImages,
                    isLoading: _isLoading,
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadRandomImages,
        tooltip: 'Load Random Images',
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
