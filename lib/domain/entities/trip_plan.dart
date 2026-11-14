import 'location.dart';

/// What the visitor asks the planner for.
class TripPlanRequest {
  const TripPlanRequest({
    required this.location,
    required this.budget,
    required this.people,
    required this.days,
    this.notes = '',
  });

  final Location location;

  /// Total for the whole group, in rupiah.
  final int budget;
  final int people;
  final int days;
  final String notes;
}

/// One line of estimated spending, for the whole group.
class PlanCost {
  const PlanCost({
    required this.category,
    required this.item,
    required this.amount,
    required this.note,
  });

  final String category;
  final String item;
  final int amount;
  final String note;
}

/// One activity in the itinerary; [location] is set when it happens at a
/// place in LokaNusantara.
class PlanStep {
  const PlanStep({
    required this.day,
    required this.time,
    required this.activity,
    this.location,
  });

  final int day;
  final String time;
  final String activity;
  final Location? location;
}

/// A generated visit plan. Totals come from the server, which sums [costs].
class TripPlan {
  const TripPlan({
    required this.summary,
    required this.budget,
    required this.people,
    required this.days,
    required this.totalEstimate,
    required this.perPersonEstimate,
    required this.withinBudget,
    required this.budgetNote,
    required this.costs,
    required this.itinerary,
    required this.tips,
  });

  final String summary;
  final int budget;
  final int people;
  final int days;
  final int totalEstimate;
  final int perPersonEstimate;
  final bool withinBudget;
  final String budgetNote;
  final List<PlanCost> costs;
  final List<PlanStep> itinerary;
  final List<String> tips;

  /// Budget minus estimate; negative when the plan goes over budget.
  int get remaining => budget - totalEstimate;
}
