import '../../core/api/api_client.dart';
import '../../domain/entities/category.dart';
import '../models/models.dart';

class CategoryRemoteDataSource {
  const CategoryRemoteDataSource(this._api);
  final ApiClient _api;

  Future<List<Category>> getAll(int limit, int offset) async {
    final res = await _api.get(
      '/categories',
      query: {'limit': limit, 'offset': offset},
    );
    return dataList(res).map(CategoryModel.fromJson).toList();
  }
}
