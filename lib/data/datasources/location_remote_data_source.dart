import '../../core/api/api_client.dart';
import '../../domain/entities/location.dart';
import '../models/models.dart';

class LocationRemoteDataSource {
  const LocationRemoteDataSource(this._api);
  final ApiClient _api;

  Future<List<Location>> getAll(int limit, int offset) async {
    final res = await _api.get(
      '/locations',
      query: {'limit': limit, 'offset': offset},
    );
    return dataList(res).map(LocationModel.fromJson).toList();
  }

  Future<Location> getById(String id) async {
    final res = await _api.get('/locations/$id');
    return LocationModel.fromJson(res as Json);
  }

  Future<List<Location>> getByCategory(
    int categoryId,
    int limit,
    int offset,
  ) async {
    final res = await _api.get(
      '/categories/$categoryId/locations',
      query: {'limit': limit, 'offset': offset},
    );
    return dataList(res).map(LocationModel.fromJson).toList();
  }

  Future<List<Location>> search(String keyword, int limit, int offset) async {
    final res = await _api.get(
      '/locations/search',
      query: {'q': keyword, 'limit': limit, 'offset': offset},
    );
    return dataList(res).map(LocationModel.fromJson).toList();
  }

  Future<List<Location>> getNearby(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    final res = await _api.get(
      '/locations/nearby',
      query: {'lat': latitude, 'lon': longitude, 'radius': radiusKm},
    );
    return dataList(res).map(LocationModel.fromJson).toList();
  }
}
