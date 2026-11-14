import '../../core/api/api_client.dart';
import '../../domain/entities/trip_plan.dart';
import '../models/models.dart';

class PlannerRemoteDataSource {
  const PlannerRemoteDataSource(this._api);
  final ApiClient _api;

  Future<TripPlan> createPlan(TripPlanRequest request) async {
    final res = await _api.post(
      '/planner',
      data: {
        'location_id': request.location.id,
        'budget': request.budget,
        'people': request.people,
        'days': request.days,
        'notes': request.notes.trim(),
      },
      // The AI can take a while; the server gives up after 85s.
      timeout: const Duration(seconds: 95),
    );
    return TripPlanModel.fromJson(res as Json);
  }
}
