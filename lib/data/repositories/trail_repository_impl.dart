import '../../domain/entities/trail.dart';
import '../../domain/repositories/trail_repository.dart';
import '../datasources/trail_remote_data_source.dart';
import 'guard.dart';

class TrailRepositoryImpl implements TrailRepository {
  const TrailRepositoryImpl(this._remote);
  final TrailRemoteDataSource _remote;

  @override
  Future<List<Trail>> getTrails() => guard(_remote.getTrails);
}
