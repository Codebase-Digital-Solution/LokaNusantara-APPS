import '../entities/location.dart';
import '../repositories/location_repository.dart';

class GetLocationsUseCase {
  const GetLocationsUseCase(this._repository);
  final LocationRepository _repository;

  Future<List<Location>> execute({int limit = 20, int offset = 0}) =>
      _repository.getAll(limit: limit, offset: offset);
}

class GetLocationByIdUseCase {
  const GetLocationByIdUseCase(this._repository);
  final LocationRepository _repository;

  Future<Location> execute(String id) => _repository.getById(id);
}

class GetLocationsByCategoryUseCase {
  const GetLocationsByCategoryUseCase(this._repository);
  final LocationRepository _repository;

  Future<List<Location>> execute(
    int categoryId, {
    int limit = 20,
    int offset = 0,
  }) => _repository.getByCategory(categoryId, limit: limit, offset: offset);
}

class SearchLocationsUseCase {
  const SearchLocationsUseCase(this._repository);
  final LocationRepository _repository;

  Future<List<Location>> execute(
    String keyword, {
    int limit = 20,
    int offset = 0,
  }) {
    if (keyword.trim().isEmpty) {
      throw ArgumentError('Search keyword is required');
    }
    return _repository.search(keyword.trim(), limit: limit, offset: offset);
  }
}

class GetNearbyLocationsUseCase {
  const GetNearbyLocationsUseCase(this._repository);
  final LocationRepository _repository;

  Future<List<Location>> execute(
    double latitude,
    double longitude, {
    double radiusKm = 5,
  }) {
    if (latitude < -90 || latitude > 90) {
      throw ArgumentError('Invalid latitude');
    }
    if (longitude < -180 || longitude > 180) {
      throw ArgumentError('Invalid longitude');
    }
    if (radiusKm <= 0) {
      throw ArgumentError('Radius must be greater than 0');
    }
    return _repository.getNearby(latitude, longitude, radiusKm);
  }
}
