class ImageModel {
  final String id;
  final String url;
  final String thumbnailUrl;
  final String description;
  final int width;
  final int height;
  final String author;
  final String authorUrl;

  ImageModel({
    required this.id,
    required this.url,
    required this.thumbnailUrl,
    required this.description,
    required this.width,
    required this.height,
    required this.author,
    required this.authorUrl,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id']?.toString() ?? '',
      url: json['webformatURL'] ?? json['largeImageURL'] ?? '',
      thumbnailUrl: json['previewURL'] ?? json['webformatURL'] ?? '',
      description: json['tags'] ?? 'No description',
      width: json['imageWidth'] ?? 0,
      height: json['imageHeight'] ?? 0,
      author: json['user'] ?? 'Unknown',
      authorUrl: 'https://pixabay.com/users/${json['user'] ?? ''}-${json['user_id'] ?? ''}/',
    );
  }
}
