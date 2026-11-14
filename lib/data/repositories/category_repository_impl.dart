import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_data_source.dart';
import 'guard.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._remote);
  final CategoryRemoteDataSource _remote;

  @override
  Future<List<Category>> getAll({required int limit, required int offset}) =>
      guard(() => _remote.getAll(limit, offset));
}
