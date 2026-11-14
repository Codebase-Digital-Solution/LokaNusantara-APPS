import 'location.dart';

/// A cultural or religious occasion in the Agenda Budaya.
class CulturalEvent {
  const CulturalEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.startDate,
    this.endDate,
    this.isEstimate = false,
    this.region = '',
    this.location,
  });

  final int id;
  final String name;
  final String description;

  /// Category key such as "pura" or "tradisi", matching location categories.
  final String category;

  /// Date only (local midnight).
  final DateTime startDate;
  final DateTime? endDate;

  /// True when the date follows a lunar calendar or an organiser's decision
  /// and may still change.
  final bool isEstimate;
  final String region;
  final Location? location;

  DateTime get lastDay => endDate ?? startDate;
  bool get isMultiDay => endDate != null && endDate!.isAfter(startDate);
}
