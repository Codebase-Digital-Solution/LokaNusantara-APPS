import '../../core/utils/helpers.dart';
import '../entities/trail.dart';
import '../repositories/trail_repository.dart';

class GetTrailsUseCase {
  const GetTrailsUseCase(this._repository);
  final TrailRepository _repository;

  /// Trails with at least two stops (a route needs a start and an end).
  Future<List<Trail>> execute() async => (await _repository.getTrails())
      .where((t) => t.stops.length >= 2)
      .toList();
}

/// Straight-line length of a trail in km, summed stop to stop.
double trailDistanceKm(Trail trail) {
  var total = 0.0;
  for (var i = 1; i < trail.stops.length; i++) {
    final a = trail.stops[i - 1].location;
    final b = trail.stops[i].location;
    total += calculateDistance(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );
  }
  return total;
}
