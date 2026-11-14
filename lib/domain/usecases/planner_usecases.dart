import '../entities/trip_plan.dart';
import '../repositories/planner_repository.dart';

/// Which form field failed validation, so the UI can word it in the app
/// language.
enum PlanInputProblem { budget, people, days, notes }

/// A plan form value outside the allowed limits. The message stays in
/// Indonesian for logs; the UI translates [problem].
class PlanInputError extends ArgumentError {
  PlanInputError(this.problem, String super.message);

  final PlanInputProblem problem;
}

/// Asks the AI planner for a visit plan, after checking the form values
/// against the same limits the server enforces.
class CreateTripPlanUseCase {
  const CreateTripPlanUseCase(this._repository);
  final PlannerRepository _repository;

  static const minBudget = 10000;
  static const maxPeople = 50;
  static const maxDays = 7;
  static const maxNotes = 300;

  Future<TripPlan> execute(TripPlanRequest request) {
    if (request.budget < minBudget) {
      throw PlanInputError(PlanInputProblem.budget, 'Budget minimal Rp10.000');
    }
    if (request.people < 1 || request.people > maxPeople) {
      throw PlanInputError(
        PlanInputProblem.people,
        'Jumlah orang harus 1 sampai $maxPeople',
      );
    }
    if (request.days < 1 || request.days > maxDays) {
      throw PlanInputError(
        PlanInputProblem.days,
        'Lama kunjungan harus 1 sampai $maxDays hari',
      );
    }
    if (request.notes.trim().length > maxNotes) {
      throw PlanInputError(
        PlanInputProblem.notes,
        'Catatan maksimal $maxNotes karakter',
      );
    }
    return _repository.createPlan(request);
  }
}
