import 'package:bali_guide_map/domain/usecases/location_usecases.dart';
import 'package:bali_guide_map/domain/usecases/review_usecases.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes.dart';

void main() {
  late FakeLocationRepository repo;

  setUp(() => repo = FakeLocationRepository());

  group('SearchLocationsUseCase', () {
    test('rejects an empty keyword', () {
      expect(
        () => SearchLocationsUseCase(repo).execute('   '),
        throwsArgumentError,
      );
    });

    test('trims the keyword', () async {
      await SearchLocationsUseCase(repo).execute('  ubud ');
      expect(repo.lastKeyword, 'ubud');
    });
  });

  group('GetNearbyLocationsUseCase', () {
    final useCase = GetNearbyLocationsUseCase(FakeLocationRepository());

    test('rejects invalid coordinates and radius', () {
      expect(() => useCase.execute(91, 0), throwsArgumentError);
      expect(() => useCase.execute(0, 181), throwsArgumentError);
      expect(() => useCase.execute(0, 0, radiusKm: 0), throwsArgumentError);
    });

    test('returns locations for valid input', () async {
      expect(await useCase.execute(-8.6, 115.2), hasLength(2));
    });
  });

  test('CreateReviewUseCase rejects ratings outside 1..5', () {
    final useCase = CreateReviewUseCase(FakeReviewRepository());
    expect(
      () => useCase.execute(locationId: 'l', rating: 0),
      throwsArgumentError,
    );
    expect(
      () => useCase.execute(locationId: 'l', rating: 6),
      throwsArgumentError,
    );
  });
}
