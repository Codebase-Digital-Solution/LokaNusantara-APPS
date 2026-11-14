import 'package:bali_guide_map/data/datasources/local_preferences_data_source.dart';
import 'package:bali_guide_map/data/repositories/local_repositories.dart';
import 'package:bali_guide_map/domain/entities/category.dart';
import 'package:bali_guide_map/domain/entities/location.dart';
import 'package:bali_guide_map/domain/entities/user.dart';
import 'package:bali_guide_map/domain/usecases/auth_usecases.dart';
import 'package:bali_guide_map/domain/usecases/collection_usecases.dart';
import 'package:bali_guide_map/presentation/providers/auth_provider.dart';
import 'package:bali_guide_map/domain/usecases/review_usecases.dart';
import 'package:bali_guide_map/presentation/providers/collections_provider.dart';
import 'package:bali_guide_map/presentation/providers/review_provider.dart';
import 'package:bali_guide_map/presentation/screens/location_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes.dart';

Widget _providers(Widget child) {
  final reviews = FakeReviewRepository();
  final places = PlaceCollectionRepositoryImpl(LocalPreferencesDataSource());
  final bookmarks = FakeBookmarkRepository();
  final authRepo = FakeAuthRepository(
    user: const User(id: 'u1', name: 'U', email: 'u@x'),
  );
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => AuthProvider(
          restoreSession: RestoreSessionUseCase(authRepo),
          loginWithGoogle: LoginWithGoogleUseCase(authRepo),
          logout: LogoutUseCase(authRepo),
        )..checkAuth(),
      ),
      ChangeNotifierProvider(
        create: (_) => ReviewProvider(
          getReviews: GetReviewsForLocationUseCase(reviews),
          getAverageRating: GetAverageRatingUseCase(reviews),
          createReview: CreateReviewUseCase(reviews),
        ),
      ),
      ChangeNotifierProxyProvider<AuthProvider, CollectionsProvider>(
        create: (_) => CollectionsProvider(
          repository: places,
          loadSaved: LoadSavedPlacesUseCase(bookmarks, places),
          toggleSaved: ToggleSavedPlaceUseCase(bookmarks),
          recordRecent: RecordRecentPlaceUseCase(places),
        ),
        update: (_, auth, c) => c!..setUser(auth.user?.id),
      ),
    ],
    child: child,
  );
}

Widget _wrap(Location location, {LatLng? user}) => _providers(
  MaterialApp(
    home: LocationDetailScreen(location: location, userLocation: user),
  ),
);

const _pura = Location(
  id: 'p1',
  name: 'Pura Tanah Lot',
  description: 'Pura di atas batu karang.',
  latitude: -8.621,
  longitude: 115.0866,
  address: 'Beraban, Tabanan',
  categoryId: 2,
  category: Category(id: 2, name: 'pura'),
  history: 'Didirikan berdasarkan kisah Dang Hyang Nirartha.',
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows history, etiquette and address', (tester) async {
    await tester.pumpWidget(_wrap(_pura));

    expect(find.text('Sejarah'), findsOneWidget);
    expect(
      find.textContaining('Dang Hyang Nirartha', findRichText: true),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(find.text('Etika Berkunjung'), 200);
    expect(find.textContaining('kamen'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Beraban, Tabanan'), 200);
    expect(find.text('Beraban, Tabanan'), findsOneWidget);
  });

  testWidgets('shows a placeholder when history is empty', (tester) async {
    const plain = Location(
      id: 'x',
      name: 'Tempat',
      description: '',
      latitude: -8.6,
      longitude: 115.2,
      address: '',
      categoryId: 1,
    );
    await tester.pumpWidget(_wrap(plain));
    expect(
      find.text('Kisah sejarah tempat ini belum tersedia.'),
      findsOneWidget,
    );
  });

  testWidgets('route button is disabled without user location', (tester) async {
    await tester.pumpWidget(_wrap(_pura));
    final button = tester.widget<ButtonStyleButton>(
      find.ancestor(
        of: find.text('Lihat Rute'),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      ),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('bookmark toggles the saved state', (tester) async {
    await tester.pumpWidget(_wrap(_pura));
    await tester.pump(); // let the signed-in session restore
    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    await tester.tap(find.byIcon(Icons.bookmark_border));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byIcon(Icons.bookmark), findsOneWidget);
  });

  testWidgets('route button pops with the route action', (tester) async {
    LocationDetailAction? result;
    await tester.pumpWidget(
      _providers(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LocationDetailScreen(
                      location: _pura,
                      userLocation: LatLng(-8.65, 115.2),
                    ),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lihat Rute'));
    await tester.pumpAndSettle();
    expect(result, LocationDetailAction.route);
  });
}
