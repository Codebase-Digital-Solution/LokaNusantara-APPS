import 'package:bali_guide_map/data/datasources/local_preferences_data_source.dart';
import 'package:bali_guide_map/data/models/models.dart';
import 'package:bali_guide_map/data/repositories/local_repositories.dart';
import 'package:bali_guide_map/domain/entities/assistant_message.dart';
import 'package:bali_guide_map/domain/entities/location.dart';
import 'package:bali_guide_map/domain/repositories/assistant_repository.dart';
import 'package:bali_guide_map/domain/usecases/assistant_usecases.dart';
import 'package:bali_guide_map/domain/usecases/collection_usecases.dart';
import 'package:bali_guide_map/domain/usecases/location_usecases.dart';
import 'package:bali_guide_map/domain/usecases/review_usecases.dart';
import 'package:bali_guide_map/domain/usecases/trail_usecases.dart';
import 'package:bali_guide_map/core/error/errors.dart';
import 'package:bali_guide_map/presentation/providers/collections_provider.dart';
import 'package:bali_guide_map/presentation/providers/review_provider.dart';
import 'package:bali_guide_map/presentation/providers/tanya_loka_provider.dart';
import 'package:bali_guide_map/presentation/screens/location_detail_screen.dart';
import 'package:bali_guide_map/presentation/screens/tanya_loka_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes.dart';
import 'audio_guide_test.dart' show FakeSpeech;

class _FakeAssistant implements AssistantRepository {
  final asked = <String>[];
  final histories = <int>[];
  bool fail = false;

  @override
  Future<ChatMessage> ask(String question, List<ChatMessage> history) async {
    asked.add(question);
    histories.add(history.length);
    if (fail) throw const NetworkError();
    return ChatMessage(
      role: ChatRole.assistant,
      text: 'Galungan adalah hari kemenangan dharma.',
      locations: [loc('7', category: 'pura')],
    );
  }
}

void main() {
  group('Jalur Kisah', () {
    test('TrailModel sorts stops and skips stops without a location', () {
      final trail = TrailModel.fromJson({
        'id': 1,
        'slug': 'jejak',
        'title': 'Jejak',
        'color': '#A87618',
        'stops': [
          {
            'position': 2,
            'note': 'b',
            'location': {'id': 'b', 'name': 'B'},
          },
          {
            'position': 1,
            'note': 'a',
            'location': {'id': 'a', 'name': 'A'},
          },
          {'position': 3, 'note': 'gone'},
        ],
      });
      expect(trail.stops.map((s) => s.location.id), ['a', 'b']);
      expect(trail.colorHex, '#A87618');
    });

    test('trailDistanceKm sums stop-to-stop distances', () {
      final trail = TrailModel.fromJson({
        'id': 1,
        'stops': [
          {
            'position': 1,
            'location': {'id': 'a', 'latitude': -8.6, 'longitude': 115.2},
          },
          {
            'position': 2,
            'location': {'id': 'b', 'latitude': -8.6, 'longitude': 115.2},
          },
        ],
      });
      expect(trailDistanceKm(trail), 0);
    });
  });

  group('Tanya Loka', () {
    test('send appends question and answer, passing earlier history', () async {
      final repo = _FakeAssistant();
      final provider = TanyaLokaProvider(ask: AskLokaUseCase(repo));

      expect(await provider.send('Apa itu Galungan?'), isTrue);
      expect(await provider.send('Kapan Kuningan?'), isTrue);

      expect(provider.messages, hasLength(4));
      expect(provider.messages.last.locations.single.id, '7');
      expect(repo.histories, [0, 2]);
    });

    test('a failed question is removed so roles keep alternating', () async {
      final repo = _FakeAssistant()..fail = true;
      final provider = TanyaLokaProvider(ask: AskLokaUseCase(repo));

      expect(await provider.send('Halo'), isFalse);
      expect(provider.messages, isEmpty);
      expect(provider.error, isNotNull);
      expect(provider.sending, isFalse);
    });

    test('rejects empty and overly long questions', () {
      final useCase = AskLokaUseCase(_FakeAssistant());
      expect(() => useCase.execute('  ', const []), throwsArgumentError);
      expect(() => useCase.execute('a' * 501, const []), throwsArgumentError);
    });

    testWidgets('tapping a suggestion asks it and shows place chips', (
      tester,
    ) async {
      final repo = _FakeAssistant();
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => TanyaLokaProvider(ask: AskLokaUseCase(repo)),
          child: const MaterialApp(home: TanyaLokaScreen()),
        ),
      );
      await tester.tap(find.text('Apa itu Hari Raya Galungan?'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(repo.asked, ['Apa itu Hari Raya Galungan?']);
      expect(
        find.text('Galungan adalah hari kemenangan dharma.'),
        findsOneWidget,
      );
      expect(find.text('Place 7'), findsOneWidget);
    });
  });

  testWidgets('detail page loads the full record when history is missing', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final locations = FakeLocationRepository()
      ..all = [
        const Location(
          id: '1',
          name: 'Pura Lengkap',
          description: 'Deskripsi lengkap.',
          latitude: -8.6,
          longitude: 115.2,
          address: '',
          categoryId: 1,
          history: 'Sejarah lengkap dari server.',
        ),
      ];
    final reviews = FakeReviewRepository();
    final places = PlaceCollectionRepositoryImpl(LocalPreferencesDataSource());

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<GetLocationByIdUseCase>.value(
            value: GetLocationByIdUseCase(locations),
          ),
          ChangeNotifierProvider(
            create: (_) => ReviewProvider(
              getReviews: GetReviewsForLocationUseCase(reviews),
              getAverageRating: GetAverageRatingUseCase(reviews),
              createReview: CreateReviewUseCase(reviews),
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => CollectionsProvider(
              repository: places,
              loadSaved: LoadSavedPlacesUseCase(
                FakeBookmarkRepository(),
                places,
              ),
              toggleSaved: ToggleSavedPlaceUseCase(FakeBookmarkRepository()),
              recordRecent: RecordRecentPlaceUseCase(places),
            ),
          ),
        ],
        child: MaterialApp(
          home: LocationDetailScreen(
            location: const Location(
              id: '1',
              name: 'Pura Lengkap',
              description: '',
              latitude: -8.6,
              longitude: 115.2,
              address: '',
              categoryId: 1,
            ),
            speechEngine: FakeSpeech.new,
          ),
        ),
      ),
    );
    expect(
      find.text('Kisah sejarah tempat ini belum tersedia.'),
      findsOneWidget,
    );
    await tester.pump();
    expect(
      find.textContaining('Sejarah lengkap', findRichText: true),
      findsOneWidget,
    );
  });
}
