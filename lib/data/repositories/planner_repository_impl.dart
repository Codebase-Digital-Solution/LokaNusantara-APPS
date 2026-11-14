import '../../domain/entities/trip_plan.dart';
import '../../domain/repositories/planner_repository.dart';
import '../datasources/planner_remote_data_source.dart';
import 'guard.dart';

class PlannerRepositoryImpl implements PlannerRepository {
  const PlannerRepositoryImpl(this._remote);
  final PlannerRemoteDataSource _remote;

  @override
  Future<TripPlan> createPlan(TripPlanRequest request) =>
      guard(() => _remote.createPlan(request));
}
