import '../entities/trip_plan.dart';

abstract interface class PlannerRepository {
  Future<TripPlan> createPlan(TripPlanRequest request);
}
