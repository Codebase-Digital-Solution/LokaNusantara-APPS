import 'package:bali_guide_map/core/error/errors.dart';
import 'package:bali_guide_map/data/models/models.dart';
import 'package:bali_guide_map/domain/entities/location.dart';
import 'package:bali_guide_map/domain/entities/saved_plan.dart';
import 'package:bali_guide_map/domain/entities/trip_plan.dart';
import 'package:bali_guide_map/domain/repositories/saved_plan_repository.dart';
import 'package:bali_guide_map/domain/usecases/saved_plan_usecases.dart';
import 'package:bali_guide_map/presentation/providers/saved_plans_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes.dart';

class _FakePlans implements SavedPlanRepository {
  final rows = <SavedPlan>[];
  AppError? failWith;
  int _next = 1;

  @override
  Future<List<SavedPlan>> getAll() async {
    if (failWith != null) throw failWith!;
    return List.of(rows);
  }

  @override
  Future<SavedPlan> save(Location location, TripPlan plan) async {
    if (failWith != null) throw failWith!;
    final saved = SavedPlan(
      id: _next++,
      location: location,
      plan: plan,
      createdAt: DateTime(2026, 11, 12),
    );
    rows.insert(0, saved);
    return saved;
  }

  @override
  Future<void> delete(int id) async {
    if (failWith != null) throw failWith!;
    rows.removeWhere((r) => r.id == id);
  }
}

TripPlan _plan() => TripPlan(
  summary: 's',
  budget: 500000,
  people: 2,
  days: 1,
  totalEstimate: 200000,
  perPersonEstimate: 100000,
  withinBudget: true,
  budgetNote: '',
  costs: const [
    PlanCost(category: 'makan', item: 'Makan', amount: 200000, note: ''),
  ],
  itinerary: [
    PlanStep(
      day: 1,
      time: '09:00',
      activity: 'Berkunjung',
      location: loc('p1'),
    ),
  ],
  tips: const ['Bawa air'],
);

SavedPlansProvider _provider(_FakePlans repo) => SavedPlansProvider(
  getAll: GetSavedPlansUseCase(repo),
  save: SavePlanUseCase(repo),
  delete: DeleteSavedPlanUseCase(repo),
);

Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  test('saving requires a signed-in user', () {
    final provider = _provider(_FakePlans());
    expect(
      () => provider.save(loc('1'), _plan()),
      throwsA(isA<UnauthorizedError>()),
    );
  });

  test(
    'plans load per account, save puts newest first, sign out clears',
    () async {
      final repo = _FakePlans();
      final provider = _provider(repo)..setUser('u1');
      await settle();
      expect(provider.plans, isEmpty);

      await provider.save(loc('1'), _plan());
      await provider.save(loc('2'), _plan());
      expect(provider.plans.map((p) => p.location.id), ['2', '1']);

      provider.setUser(null);
      await settle();
      expect(provider.plans, isEmpty);
    },
  );

  test('a failed delete puts the plan back', () async {
    final repo = _FakePlans();
    final provider = _provider(repo)..setUser('u1');
    await settle();
    await provider.save(loc('1'), _plan());
    repo.failWith = const NetworkError();
    await expectLater(
      provider.delete(provider.plans.single.id),
      throwsA(isA<NetworkError>()),
    );
    expect(provider.plans, hasLength(1));
  });

  test('a plan survives the JSON round trip used to save it', () {
    final json = TripPlanModel.toJson(_plan());
    final back = TripPlanModel.fromJson(json);
    expect(back.totalEstimate, 200000);
    expect(back.costs.single.item, 'Makan');
    expect(back.itinerary.single.location?.id, 'p1');
    expect(back.tips, ['Bawa air']);

    final saved = SavedPlanModel.fromJson({
      'id': 7,
      'location': loc('1').toJson(),
      'plan': json,
      'created_at': '2026-11-12T10:00:00Z',
    });
    expect(saved.id, 7);
    expect(saved.location.id, '1');
    expect(saved.plan.people, 2);
  });
}
