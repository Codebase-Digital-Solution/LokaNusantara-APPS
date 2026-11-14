import 'category.dart';

class Location {
  const Location({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.categoryId,
    this.category,
    this.history = '',
    this.imageUrl,
  });

  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final int categoryId;
  final Category? category;

  /// Longer historical and cultural background; may be empty.
  final String history;

  /// Cover photo URL. Null until the API provides images; the UI then shows
  /// a placeholder.
  final String? imageUrl;
}
