import '../entities/location.dart';

abstract interface class LocationRepository {
  Future<List<Location>> getAll({required int limit, required int offset});
  Future<Location> getById(String id);
  Future<List<Location>> getByCategory(
    int categoryId, {
    required int limit,
    required int offset,
  });
  Future<List<Location>> search(
    String keyword, {
    required int limit,
    required int offset,
  });
  Future<List<Location>> getNearby(
    double latitude,
    double longitude,
    double radiusKm,
  );
}
