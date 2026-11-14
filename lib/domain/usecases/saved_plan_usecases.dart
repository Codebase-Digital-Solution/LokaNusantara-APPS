import '../entities/location.dart';
import '../entities/saved_plan.dart';
import '../entities/trip_plan.dart';
import '../repositories/saved_plan_repository.dart';

class GetSavedPlansUseCase {
  const GetSavedPlansUseCase(this._repository);
  final SavedPlanRepository _repository;

  Future<List<SavedPlan>> execute() => _repository.getAll();
}

class SavePlanUseCase {
  const SavePlanUseCase(this._repository);
  final SavedPlanRepository _repository;

  Future<SavedPlan> execute(Location location, TripPlan plan) =>
      _repository.save(location, plan);
}

class DeleteSavedPlanUseCase {
  const DeleteSavedPlanUseCase(this._repository);
  final SavedPlanRepository _repository;

  Future<void> execute(int id) => _repository.delete(id);
}
