import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategoriesUseCase {
  const GetCategoriesUseCase(this._repository);
  final CategoryRepository _repository;

  Future<List<Category>> execute({int limit = 10, int offset = 0}) =>
      _repository.getAll(limit: limit, offset: offset);
}
