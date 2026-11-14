import 'package:bali_guide_map/data/models/models.dart';
import 'package:bali_guide_map/domain/entities/cultural_event.dart';
import 'package:bali_guide_map/domain/repositories/event_repository.dart';
import 'package:bali_guide_map/domain/usecases/event_usecases.dart';
import 'package:bali_guide_map/presentation/providers/agenda_provider.dart';
import 'package:bali_guide_map/presentation/screens/agenda_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeEvents implements EventRepository {
  _FakeEvents(this.events);
  final List<CulturalEvent> events;
  DateTime? from;

  @override
  Future<List<CulturalEvent>> getEvents({
    required DateTime from,
    required DateTime to,
  }) async {
    this.from = from;
    return events;
  }
}

void main() {
  test('EventModel parses plain dates as local days', () {
    final event = EventModel.fromJson({
      'id': 3,
      'name': 'Hari Raya Galungan',
      'category': 'Pura',
      'start_date': '2027-01-13',
      'end_date': null,
      'is_estimate': false,
      'region': 'Seluruh Bali',
    });
    expect(event.startDate, DateTime(2027, 1, 13));
    expect(event.category, 'pura');
    expect(event.location, isNull);
    expect(event.isMultiDay, isFalse);
  });

  test('upcoming use case starts from the beginning of today', () async {
    final repo = _FakeEvents(const []);
    await GetUpcomingEventsUseCase(
      repo,
    ).execute(today: DateTime(2026, 11, 8, 15, 30));
    expect(repo.from, DateTime(2026, 11, 8));
  });

  testWidgets('agenda highlights the next event and filters by category', (
    tester,
  ) async {
    final repo = _FakeEvents([
      CulturalEvent(
        id: 1,
        name: 'Hari Raya Galungan',
        description: 'Kemenangan dharma.',
        category: 'pura',
        startDate: DateTime(2027, 1, 13),
        region: 'Seluruh Bali',
      ),
      CulturalEvent(
        id: 2,
        name: 'Tahun Baru Imlek',
        description: '',
        category: 'klenteng',
        startDate: DateTime(2027, 2, 6),
        region: 'Badung',
      ),
      CulturalEvent(
        id: 3,
        name: 'Hari Raya Nyepi',
        description: '',
        category: 'pura',
        startDate: DateTime(2027, 3, 8),
        isEstimate: true,
        region: 'Seluruh Bali',
      ),
    ]);
    final provider = AgendaProvider(
      getUpcoming: GetUpcomingEventsUseCase(repo),
    );
    await provider.load();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: AgendaScreen()),
      ),
    );

    expect(find.text('Segera'), findsOneWidget);
    expect(find.text('Hari Raya Galungan'), findsOneWidget);
    expect(find.text('Februari 2027'), findsOneWidget);
    expect(find.text('Perkiraan'), findsOneWidget);

    // The first match is the filter chip; event rows also show the label.
    await tester.tap(find.text('Klenteng').first);
    await tester.pumpAndSettle();
    expect(find.text('Hari Raya Galungan'), findsNothing);
    expect(find.text('Tahun Baru Imlek'), findsOneWidget);
  });
}
