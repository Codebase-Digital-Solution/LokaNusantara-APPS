import '../../core/api/api_client.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/saved_plan.dart';
import '../../domain/entities/trip_plan.dart';
import '../models/models.dart';

class SavedPlanRemoteDataSource {
  const SavedPlanRemoteDataSource(this._api);
  final ApiClient _api;

  Future<List<SavedPlan>> getAll() async {
    final res = await _api.get('/plans');
    return dataList(res).map(SavedPlanModel.fromJson).toList();
  }

  Future<SavedPlan> save(Location location, TripPlan plan) async {
    final res = await _api.post(
      '/plans',
      data: {'location_id': location.id, 'plan': TripPlanModel.toJson(plan)},
    );
    return SavedPlanModel.fromJson(res as Json);
  }

  Future<void> delete(int id) => _api.delete('/plans/$id');
}
