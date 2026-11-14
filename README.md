# LokaNusantara: Mobile App

Flutter app for Android and iOS that maps Indonesian traditions, houses of worship and traditional food. The first region covered is Bali.

## Categories

| Category | Icon motif | Examples |
|---|---|---|
| Tradisi | Gunungan wayang | Desa Penglipuran, Tenganan, Subak Jatiluwih |
| Pura | Candi bentar | Besakih, Tanah Lot, Uluwatu |
| Masjid | Kubah dan menara | Masjid Nurul Huda Gelgel, Pegayaman |
| Gereja | Menara salib | Gereja Palasari, Blimbingsari |
| Vihara | Stupa berundak | Brahmavihara-Arama |
| Klenteng | Atap melengkung bertingkat | Vihara Dharmayana Kuta |
| Kuliner | Tumpeng | Babi Guling Ibu Oka, Ayam Betutu Gilimanuk |

## Features

- Animated first-run onboarding (orbiting icons, parallax text, blended backgrounds)
- Bottom navigation: Beranda, Tersimpan, Peta (centre), Agenda, Profil
- Pinterest-style home feed: masonry grid with irregular tile heights, category chips and search
- Jalur Kisah: curated themed routes (e.g. Jejak Dang Hyang Nirartha) with a story, ordered stops and the route drawn on the map
- Pemandu Audio: on-device text-to-speech narration of each place's history, highlighting the sentence being read
- Tanya Loka: AI cultural guide (Claude, via the backend) that answers only from LokaNusantara data and links the places it mentions
- Agenda Budaya: upcoming ceremonies and festivals linked to their locations, with estimated dates labelled
- Saved destinations and recently viewed history (in Profil), stored on the device
- Detail page with history (Sejarah), visiting etiquette and all reviews
- Full-screen map with category markers and grid-based clustering
- Street map and satellite imagery, with no API key required
- Density heatmap toggle
- Category filter and real-time search
- Location detail with distance, average rating and recent reviews
- Routing by car, on foot or by bike through public OSRM servers
- Login and register, with the session stored in the platform keychain or keystore
- Star-rating reviews for signed-in users
- Live GPS position

## Tech Stack

| Concern | Package |
|---|---|
| State management | `provider` (`ChangeNotifier`) |
| HTTP | `dio` |
| Map | `flutter_map`, `latlong2` |
| Location | `geolocator` |
| Secure storage | `flutter_secure_storage` |
| Local preferences | `shared_preferences` (saved, history, onboarding flag) |
| SVG icons | `flutter_svg` |
| Text-to-speech | `flutter_tts` |

## Architecture

The app follows Clean Architecture. Dependencies point inward: `presentation` depends on `domain`, `data` implements `domain`, and `di` wires them together.

```
lib/
├── core/
│   ├── api/            # ApiClient (dio, JWT header, base URL)
│   ├── error/          # AppError hierarchy and handleError()
│   └── utils/          # distance, clustering, OSRM directions, category styles
├── domain/
│   ├── entities/       # Location, Category, Review, User, AuthSession
│   ├── repositories/   # abstract repository contracts
│   └── usecases/       # business rules and input validation
├── data/
│   ├── models/         # JSON parsing
│   ├── datasources/    # remote API calls and local session storage
│   └── repositories/   # repository implementations
├── di/
│   └── service_locator.dart
├── presentation/
│   ├── providers/      # AuthProvider, LocationProvider, ReviewProvider
│   ├── screens/        # splash, login, register, map
│   ├── widgets/        # markers, search bar, category filter, detail, review sheet
│   └── app.dart        # MultiProvider setup and root routing
└── main.dart
```

### Data Flow

```
Widget  ->  Provider  ->  UseCase  ->  Repository (interface)
                                          |
                          RepositoryImpl  ->  DataSource  ->  ApiClient / SecureStorage
```

Repositories turn every failure into an `AppError` (`NetworkError`, `UnauthorizedError`, `NotFoundError`, `ValidationError` or `ServerError`). Providers keep that error in their state for the UI to show.

## Getting Started

### Requirements

- Flutter SDK 3.44 or newer
- Android Studio with an emulator, or Xcode with a simulator
- The backend in [../api](../api) running, or a reachable deployed URL

### Run

```bash
flutter pub get

# Android emulator against a local backend
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1

# iOS simulator against a local backend
flutter run --dart-define=API_BASE_URL=http://localhost:8080/api/v1

# Default URL (the ngrok tunnel set in lib/core/api/api_client.dart)
flutter run
```

On iOS, run `cd ios && pod install` first if the build reports a CocoaPods error.

### Configuration

| Setting | Where |
|---|---|
| API base URL | `--dart-define=API_BASE_URL=...`, default in [lib/core/api/api_client.dart](lib/core/api/api_client.dart) |
| Location permission (Android) | [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml) |
| Location permission (iOS) | `NSLocationWhenInUseUsageDescription` in [ios/Runner/Info.plist](ios/Runner/Info.plist) |

## Testing

```bash
flutter analyze
flutter test
```

| Folder | Covers |
|---|---|
| `test/core/` | distance, formatting, clustering, error mapping |
| `test/data/` | JSON model parsing |
| `test/domain/` | use case validation |
| `test/presentation/` | `LocationProvider` and `ReviewProvider` state |

Shared fake repositories live in [test/fakes.dart](test/fakes.dart).

## Build

```bash
flutter build apk --release        # Android APK
flutter build appbundle --release  # Android App Bundle for Play Store
flutter build ios --release        # iOS, then archive in Xcode
```

## Brand Assets

The visual identity uses a traditional palette (terakota, prada gold, sogan brown, gading ivory) defined in [lib/presentation/theme/app_colors.dart](lib/presentation/theme/app_colors.dart), plus a batik kawung background motif drawn in code.

| File | Purpose |
|---|---|
| `assets/brand/logo_mark.svg` | Logo: gold map pin with a kawung motif |
| `assets/brand/app_icon.svg` | Full app icon with background |
| `assets/icons/*.svg` | Category glyphs |

After editing the brand SVGs, regenerate the PNGs, launcher icons and native splash:

```bash
flutter test tool/render_brand_assets_test.dart
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## API Endpoints Used

| Method | Path |
|---|---|
| POST | `/auth/login`, `/auth/register` |
| GET | `/locations`, `/locations/:id`, `/locations/search?q=`, `/locations/nearby?lat=&lon=&radius=` |
| GET | `/categories`, `/categories/:id/locations` |
| GET | `/locations/:id/reviews`, `/locations/:id/reviews/rating` |
| GET | `/events?from=YYYY-MM-DD&to=YYYY-MM-DD` |
| GET | `/trails` |
| POST | `/assistant/ask` (Tanya Loka, rate limited) |
| POST | `/reviews` (requires JWT) |

## Map Attribution

Street tiles come from [OpenStreetMap](https://www.openstreetmap.org/copyright) and satellite imagery from Esri World Imagery. Both are credited in the map's attribution button. For heavy production traffic, switch to a tile provider whose usage policy fits that load.
