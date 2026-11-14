import 'package:bali_guide_map/core/utils/currency_format.dart';
import 'package:bali_guide_map/data/models/models.dart';
import 'package:bali_guide_map/domain/entities/trip_plan.dart';
import 'package:bali_guide_map/domain/repositories/planner_repository.dart';
import 'package:bali_guide_map/domain/usecases/planner_usecases.dart';
import 'package:bali_guide_map/presentation/screens/plan_result_screen.dart';
import 'package:bali_guide_map/presentation/widgets/plan_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../fakes.dart';

class _FakePlanner implements PlannerRepository {
  TripPlanRequest? last;

  @override
  Future<TripPlan> createPlan(TripPlanRequest request) async {
    last = request;
    return TripPlan(
      summary: 'Kunjungan pagi yang santai.',
      budget: request.budget,
      people: request.people,
      days: request.days,
      totalEstimate: 350000,
      perPersonEstimate: 116667,
      withinBudget: true,
      budgetNote: 'Budget cukup longgar.',
      costs: const [
        PlanCost(
          category: 'donasi',
          item: 'Punia',
          amount: 50000,
          note: 'perkiraan',
        ),
      ],
      itinerary: [
        PlanStep(
          day: 1,
          time: '09:00',
          activity: 'Berkunjung',
          location: request.location,
        ),
      ],
      tips: const ['Bawa uang tunai'],
    );
  }
}

void main() {
  test('formatRupiah uses dot thousands separators', () {
    expect(formatRupiah(0), 'Rp0');
    expect(formatRupiah(1500), 'Rp1.500');
    expect(formatRupiah(1500000), 'Rp1.500.000');
    expect(formatRupiahShort(250000), '250rb');
    expect(formatRupiahShort(1000000), '1jt');
    expect(formatRupiahShort(1500000), '1,5jt');
    expect(formatRupiahShort(250000, languageCode: 'en'), '250K');
    expect(formatRupiahShort(1500000, languageCode: 'en'), '1.5M');
  });

  test('CreateTripPlanUseCase rejects out-of-range input', () {
    final useCase = CreateTripPlanUseCase(_FakePlanner());
    TripPlanRequest req({int budget = 500000, int people = 2, int days = 1}) =>
        TripPlanRequest(
          location: loc('1'),
          budget: budget,
          people: people,
          days: days,
        );
    expect(() => useCase.execute(req(budget: 5000)), throwsArgumentError);
    expect(() => useCase.execute(req(people: 0)), throwsArgumentError);
    expect(() => useCase.execute(req(days: 8)), throwsArgumentError);
    expect(
      () => useCase.execute(req(people: 0)),
      throwsA(
        isA<PlanInputError>().having(
          (e) => e.problem,
          'problem',
          PlanInputProblem.people,
        ),
      ),
    );
  });

  test('TripPlanModel parses the API response', () {
    final plan = TripPlanModel.fromJson({
      'summary': 's',
      'budget': 500000,
      'people': 3,
      'days': 1,
      'total_estimate': 350000,
      'per_person_estimate': 116667,
      'within_budget': true,
      'budget_note': 'n',
      'costs': [
        {'category': 'makan', 'item': 'Makan', 'amount': 150000, 'note': ''},
      ],
      'itinerary': [
        {'day': 1, 'time': '08:00', 'activity': 'Berangkat'},
        {
          'day': 1,
          'time': '09:00',
          'activity': 'Ke pura',
          'location': {'id': 'p1', 'name': 'Pura', 'latitude': -8.5},
        },
      ],
      'tips': ['a', 'b'],
    });
    expect(plan.remaining, 150000);
    expect(plan.costs.single.amount, 150000);
    expect(plan.itinerary.first.location, isNull);
    expect(plan.itinerary.last.location?.name, 'Pura');
    expect(plan.tips, ['a', 'b']);
  });

  testWidgets('filling the plan form opens the result page', (tester) async {
    final planner = _FakePlanner();
    await tester.binding.setSurfaceSize(const Size(420, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      Provider<CreateTripPlanUseCase>.value(
        value: CreateTripPlanUseCase(planner),
        child: MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showPlanSheet(context, loc('1')),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1jt'));
    await tester.tap(find.byTooltip('Tambah').first); // 3 people
    await tester.pump();
    expect(find.text('3 orang'), findsOneWidget);

    await tester.tap(find.text('Buat Rencana'));
    await tester.pumpAndSettle();

    expect(planner.last?.budget, 1000000);
    expect(planner.last?.people, 3);
    expect(find.byType(PlanResultScreen), findsOneWidget);
    expect(find.text('Sesuai budget'), findsOneWidget);
    expect(find.text('Rp650.000'), findsOneWidget); // remaining budget
  });
}
