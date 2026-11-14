import '../../domain/entities/location.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_remote_data_source.dart';
import 'guard.dart';

class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl(this._remote);
  final LocationRemoteDataSource _remote;

  @override
  Future<List<Location>> getAll({required int limit, required int offset}) =>
      guard(() => _remote.getAll(limit, offset));

  @override
  Future<Location> getById(String id) => guard(() => _remote.getById(id));

  @override
  Future<List<Location>> getByCategory(
    int categoryId, {
    required int limit,
    required int offset,
  }) => guard(() => _remote.getByCategory(categoryId, limit, offset));

  @override
  Future<List<Location>> search(
    String keyword, {
    required int limit,
    required int offset,
  }) => guard(() => _remote.search(keyword, limit, offset));

  @override
  Future<List<Location>> getNearby(
    double latitude,
    double longitude,
    double radiusKm,
  ) => guard(() => _remote.getNearby(latitude, longitude, radiusKm));
}
