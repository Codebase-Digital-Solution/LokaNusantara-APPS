import '../entities/location.dart';
import '../entities/saved_plan.dart';
import '../entities/trip_plan.dart';

/// Saved visit plans of the signed-in user, stored on the server.
abstract interface class SavedPlanRepository {
  Future<List<SavedPlan>> getAll();
  Future<SavedPlan> save(Location location, TripPlan plan);
  Future<void> delete(int id);
}
