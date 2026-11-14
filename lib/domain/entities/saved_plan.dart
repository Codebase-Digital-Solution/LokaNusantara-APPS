import 'location.dart';
import 'trip_plan.dart';

/// A visit plan the signed-in user saved to their account.
class SavedPlan {
  const SavedPlan({
    required this.id,
    required this.location,
    required this.plan,
    required this.createdAt,
  });

  final int id;
  final Location location;
  final TripPlan plan;
  final DateTime createdAt;
}
