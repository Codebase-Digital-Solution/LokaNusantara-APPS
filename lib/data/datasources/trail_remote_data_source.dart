import '../../core/api/api_client.dart';
import '../../domain/entities/trail.dart';
import '../models/models.dart';

class TrailRemoteDataSource {
  const TrailRemoteDataSource(this._api);
  final ApiClient _api;

  Future<List<Trail>> getTrails() async {
    final res = await _api.get('/trails');
    return dataList(res).map(TrailModel.fromJson).toList();
  }
}
