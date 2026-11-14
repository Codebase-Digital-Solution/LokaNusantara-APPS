import 'package:bali_guide_map/core/error/errors.dart';
import 'package:bali_guide_map/domain/usecases/category_usecases.dart';
import 'package:bali_guide_map/domain/usecases/location_usecases.dart';
import 'package:bali_guide_map/domain/usecases/review_usecases.dart';
import 'package:bali_guide_map/presentation/providers/location_provider.dart';
import 'package:bali_guide_map/presentation/providers/review_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes.dart';

LocationProvider locationProvider(FakeLocationRepository repo) =>
    LocationProvider(
      getLocations: GetLocationsUseCase(repo),
      getLocationsByCategory: GetLocationsByCategoryUseCase(repo),
      searchLocations: SearchLocationsUseCase(repo),
      getNearbyLocations: GetNearbyLocationsUseCase(repo),
      getCategories: GetCategoriesUseCase(FakeCategoryRepository()),
    );

ReviewProvider reviewProvider(FakeReviewRepository repo) => ReviewProvider(
  getReviews: GetReviewsForLocationUseCase(repo),
  getAverageRating: GetAverageRatingUseCase(repo),
  createReview: CreateReviewUseCase(repo),
);

void main() {
  group('LocationProvider', () {
    late FakeLocationRepository repo;
    late LocationProvider provider;

    setUp(() {
      repo = FakeLocationRepository();
      provider = locationProvider(repo);
    });

    test('fetchLocations fills both lists and clears loading', () async {
      await provider.fetchLocations();
      expect(provider.locations, hasLength(2));
      expect(provider.filteredLocations, hasLength(2));
      expect(provider.loading, isFalse);
      expect(provider.error, isNull);
    });

    test('fetchLocations stores the error on failure', () async {
      repo.failWith = const NetworkError();
      await provider.fetchLocations();
      expect(provider.error, isA<NetworkError>());
      expect(provider.loading, isFalse);
    });

    test('selectCategory filters, and null restores everything', () async {
      await provider.fetchLocations();
      provider.selectCategory(1);
      await Future<void>.delayed(Duration.zero);
      expect(provider.filteredLocations.single.id, '3');

      provider.selectCategory(null);
      expect(provider.filteredLocations, hasLength(2));
    });

    test('clearSearch keeps the selected location', () async {
      await provider.fetchLocations();
      await provider.searchLocations('pura');
      provider.selectLocation(provider.filteredLocations.first);
      provider.clearSearch();
      expect(provider.selectedLocation?.id, '4');
      expect(provider.searchKeyword, isEmpty);
      expect(provider.filteredLocations, hasLength(2));
    });

    test('a stale search result does not overwrite a newer state', () async {
      await provider.fetchLocations();
      final pending = provider.searchLocations('old');
      provider.clearSearch();
      await pending;
      expect(provider.filteredLocations, hasLength(2));
    });

    test('fetchCategories loads categories', () async {
      await provider.fetchCategories();
      expect(provider.categories, hasLength(2));
    });
  });

  group('ReviewProvider', () {
    test('createReview reloads reviews and average', () async {
      final provider = reviewProvider(FakeReviewRepository());
      final ok = await provider.createReview(
        locationId: 'l1',
        rating: 4,
        comment: 'bagus',
      );
      expect(ok, isTrue);
      expect(provider.reviews, hasLength(1));
      expect(provider.averageRating, 4);
      expect(provider.loading, isFalse);
    });

    test('createReview reports failure', () async {
      final repo = FakeReviewRepository()
        ..createError = const UnauthorizedError('login dulu');
      final provider = reviewProvider(repo);
      final ok = await provider.createReview(
        locationId: 'l1',
        rating: 5,
        comment: '',
      );
      expect(ok, isFalse);
      expect(provider.error?.message, 'login dulu');
      expect(provider.loading, isFalse);
    });

    test('reset clears state', () async {
      final provider = reviewProvider(FakeReviewRepository());
      await provider.createReview(locationId: 'l1', rating: 3, comment: '');
      provider.reset();
      expect(provider.reviews, isEmpty);
      expect(provider.averageRating, 0);
    });
  });
}
