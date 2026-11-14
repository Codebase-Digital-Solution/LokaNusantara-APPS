import '../../domain/entities/location.dart';
import '../../domain/repositories/bookmark_repository.dart';
import '../datasources/bookmark_remote_data_source.dart';
import 'guard.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  const BookmarkRepositoryImpl(this._remote);
  final BookmarkRemoteDataSource _remote;

  @override
  Future<List<Location>> getAll() => guard(_remote.getAll);

  @override
  Future<void> add(String locationId) => guard(() => _remote.add(locationId));

  @override
  Future<void> remove(String locationId) =>
      guard(() => _remote.remove(locationId));
}
