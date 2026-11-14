import '../entities/category.dart';

abstract interface class CategoryRepository {
  Future<List<Category>> getAll({required int limit, required int offset});
}
