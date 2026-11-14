import '../../core/api/api_client.dart';
import '../../domain/entities/location.dart';
import '../models/models.dart';

class BookmarkRemoteDataSource {
  const BookmarkRemoteDataSource(this._api);
  final ApiClient _api;

  Future<List<Location>> getAll() async {
    final res = await _api.get('/bookmarks');
    return dataList(res).map(LocationModel.fromJson).toList();
  }

  Future<void> add(String locationId) => _api.put('/bookmarks/$locationId');

  Future<void> remove(String locationId) =>
      _api.delete('/bookmarks/$locationId');
}
