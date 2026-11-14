import 'package:bali_guide_map/core/error/errors.dart';
import 'package:bali_guide_map/data/datasources/local_preferences_data_source.dart';
import 'package:bali_guide_map/data/repositories/local_repositories.dart';
import 'package:bali_guide_map/domain/usecases/collection_usecases.dart';
import 'package:bali_guide_map/presentation/providers/collections_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes.dart';

late FakeBookmarkRepository server;

CollectionsProvider _provider() {
  final device = PlaceCollectionRepositoryImpl(LocalPreferencesDataSource());
  return CollectionsProvider(
    repository: device,
    loadSaved: LoadSavedPlacesUseCase(server, device),
    toggleSaved: ToggleSavedPlaceUseCase(server),
    recordRecent: RecordRecentPlaceUseCase(device, maxItems: 3),
  );
}

/// Lets the microtask-scheduled load in setUser run to completion.
Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    server = FakeBookmarkRepository();
  });

  test('toggleSaved requires a signed-in user', () async {
    final provider = _provider();
    expect(
      () => provider.toggleSaved(loc('1')),
      throwsA(isA<UnauthorizedError>()),
    );
  });

  test('saved places are stored on the server per account', () async {
    final provider = _provider()..setUser('u1');
    await settle();

    expect(await provider.toggleSaved(loc('1')), isTrue);
    expect(provider.isSaved('1'), isTrue);
    expect(server.places.single.id, '1');

    // A fresh app start for the same user reads the server list back.
    final reloaded = _provider()..setUser('u1');
    await settle();
    expect(reloaded.saved.single.id, '1');

    expect(await reloaded.toggleSaved(loc('1')), isFalse);
    expect(server.places, isEmpty);
  });

  test('a failed save rolls back and reports the error', () async {
    final provider = _provider()..setUser('u1');
    await settle();
    server.failWith = const NetworkError();
    await expectLater(
      provider.toggleSaved(loc('1')),
      throwsA(isA<NetworkError>()),
    );
    expect(provider.isSaved('1'), isFalse);
  });

  test('signing out clears saved places and the recent history', () async {
    final provider = _provider();
    await provider.load();
    provider.setUser('u1');
    await settle();
    await provider.toggleSaved(loc('1'));
    await provider.recordView(loc('a'));

    provider.setUser(null);
    await settle();
    expect(provider.saved, isEmpty);
    expect(provider.recent, isEmpty);

    // Nothing left on the device either.
    final next = _provider();
    await next.load();
    expect(next.recent, isEmpty);
  });

  test('restoring a session at startup keeps the recent history', () async {
    final provider = _provider();
    await provider.load();
    await provider.recordView(loc('a'));
    provider.setUser(null); // auth not restored yet: must not wipe anything
    provider.setUser('u1');
    await settle();
    expect(provider.recent.single.id, 'a');
  });

  test(
    'bookmarks saved on the device by older versions are uploaded once',
    () async {
      final device = PlaceCollectionRepositoryImpl(
        LocalPreferencesDataSource(),
      );
      await device.setSaved([loc('new'), loc('old')]);

      final provider = _provider()..setUser('u1');
      await settle();
      expect(provider.saved.map((l) => l.id), ['new', 'old']);
      expect(await device.getSaved(), isEmpty);
    },
  );

  test(
    'recordView keeps newest first, deduplicates and caps the list',
    () async {
      final provider = _provider();
      await provider.load();
      for (final id in ['a', 'b', 'c', 'a', 'd']) {
        await provider.recordView(loc(id));
      }
      expect(provider.recent.map((l) => l.id), ['d', 'a', 'c']);
    },
  );

  test('clearRecent empties the history', () async {
    final provider = _provider();
    await provider.load();
    await provider.recordView(loc('a'));
    await provider.clearRecent();
    expect(provider.recent, isEmpty);
  });

  test('onboarding flag round-trips', () async {
    final repo = OnboardingRepositoryImpl(LocalPreferencesDataSource());
    expect(await repo.isCompleted(), isFalse);
    await repo.setCompleted(true);
    expect(await repo.isCompleted(), isTrue);
  });
}
