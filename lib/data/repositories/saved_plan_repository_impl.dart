import '../../domain/entities/location.dart';
import '../../domain/entities/saved_plan.dart';
import '../../domain/entities/trip_plan.dart';
import '../../domain/repositories/saved_plan_repository.dart';
import '../datasources/saved_plan_remote_data_source.dart';
import 'guard.dart';

class SavedPlanRepositoryImpl implements SavedPlanRepository {
  const SavedPlanRepositoryImpl(this._remote);
  final SavedPlanRemoteDataSource _remote;

  @override
  Future<List<SavedPlan>> getAll() => guard(_remote.getAll);

  @override
  Future<SavedPlan> save(Location location, TripPlan plan) =>
      guard(() => _remote.save(location, plan));

  @override
  Future<void> delete(int id) => guard(() => _remote.delete(id));
}
