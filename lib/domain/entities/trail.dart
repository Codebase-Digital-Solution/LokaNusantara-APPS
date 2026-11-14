import 'location.dart';

/// A curated themed route ("Jalur Kisah") through several locations.
class Trail {
  const Trail({
    required this.id,
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.story,
    required this.colorHex,
    required this.stops,
    this.imageUrl,
  });

  final int id;
  final String slug;
  final String title;
  final String subtitle;
  final String story;

  /// Theme colour as "#RRGGBB".
  final String colorHex;
  final List<TrailStop> stops;

  /// Cover photo, absolute URL; null when the trail has none yet.
  final String? imageUrl;
}

class TrailStop {
  const TrailStop({
    required this.position,
    required this.note,
    required this.location,
  });

  final int position;
  final String note;
  final Location location;
}
