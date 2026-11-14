import '../core/api/api_client.dart';
import '../core/utils/directions.dart';
import '../core/auth/google_auth_service.dart';
import '../core/notifications/agenda_reminders.dart';
import '../core/notifications/local_reminder_scheduler.dart';
import '../data/datasources/auth_local_data_source.dart';
import '../domain/repositories/reminder_settings_repository.dart';
import '../presentation/providers/agenda_reminders_provider.dart';
import '../data/datasources/bookmark_remote_data_source.dart';
import '../data/datasources/planner_remote_data_source.dart';
import '../data/datasources/saved_plan_remote_data_source.dart';
import '../data/repositories/saved_plan_repository_impl.dart';
import '../domain/usecases/saved_plan_usecases.dart';
import '../presentation/providers/saved_plans_provider.dart';
import '../data/repositories/planner_repository_impl.dart';
import '../domain/usecases/planner_usecases.dart';
import '../data/repositories/bookmark_repository_impl.dart';
import '../domain/repositories/bookmark_repository.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/datasources/category_remote_data_source.dart';
import '../data/datasources/assistant_remote_data_source.dart';
import '../data/datasources/event_remote_data_source.dart';
import '../data/datasources/local_preferences_data_source.dart';
import '../data/datasources/trail_remote_data_source.dart';
import '../data/datasources/location_remote_data_source.dart';
import '../data/datasources/review_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/category_repository_impl.dart';
import '../data/repositories/assistant_repository_impl.dart';
import '../data/repositories/event_repository_impl.dart';
import '../data/repositories/local_repositories.dart';
import '../data/repositories/trail_repository_impl.dart';
import '../data/repositories/location_repository_impl.dart';
import '../data/repositories/review_repository_impl.dart';
import '../domain/usecases/assistant_usecases.dart';
import '../domain/usecases/auth_usecases.dart';
import '../domain/repositories/onboarding_repository.dart';
import '../domain/repositories/place_collection_repository.dart';
import '../domain/usecases/category_usecases.dart';
import '../domain/usecases/collection_usecases.dart';
import '../domain/usecases/event_usecases.dart';
import '../domain/usecases/trail_usecases.dart';
import '../domain/usecases/location_usecases.dart';
import '../domain/usecases/review_usecases.dart';
import '../presentation/providers/agenda_provider.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/providers/collections_provider.dart';
import '../presentation/providers/locale_provider.dart';
import '../presentation/providers/location_provider.dart';
import '../presentation/providers/review_provider.dart';
import '../presentation/providers/tanya_loka_provider.dart';
import '../presentation/providers/trail_provider.dart';

/// Wires data sources, repositories and use cases into the providers.
class ServiceLocator {
  ServiceLocator({ApiClient? apiClient, LocalPreferencesDataSource? prefs})
    : apiClient = apiClient ?? ApiClient(),
      _prefs = prefs ?? LocalPreferencesDataSource() {
    collections = PlaceCollectionRepositoryImpl(_prefs);
    bookmarks = BookmarkRepositoryImpl(
      BookmarkRemoteDataSource(this.apiClient),
    );
    onboarding = OnboardingRepositoryImpl(_prefs);
    reminderSettings = ReminderSettingsRepositoryImpl(_prefs);

    final locationRepo = LocationRepositoryImpl(
      LocationRemoteDataSource(this.apiClient),
    );
    final categoryRepo = CategoryRepositoryImpl(
      CategoryRemoteDataSource(this.apiClient),
    );
    final reviewRepo = ReviewRepositoryImpl(
      ReviewRemoteDataSource(this.apiClient),
    );
    final authRepo = AuthRepositoryImpl(
      this.apiClient,
      AuthRemoteDataSource(this.apiClient),
      const AuthLocalDataSource(),
      GoogleAuthService(),
    );

    locationById = GetLocationByIdUseCase(locationRepo);
    final savedPlanRepo = SavedPlanRepositoryImpl(
      SavedPlanRemoteDataSource(this.apiClient),
    );
    _savedPlanUseCases = (
      getAll: GetSavedPlansUseCase(savedPlanRepo),
      save: SavePlanUseCase(savedPlanRepo),
      delete: DeleteSavedPlanUseCase(savedPlanRepo),
    );
    createTripPlan = CreateTripPlanUseCase(
      PlannerRepositoryImpl(PlannerRemoteDataSource(this.apiClient)),
    );
    _locationUseCases = (
      getLocations: GetLocationsUseCase(locationRepo),
      byCategory: GetLocationsByCategoryUseCase(locationRepo),
      search: SearchLocationsUseCase(locationRepo),
      nearby: GetNearbyLocationsUseCase(locationRepo),
      categories: GetCategoriesUseCase(categoryRepo),
    );
    _reviewUseCases = (
      getReviews: GetReviewsForLocationUseCase(reviewRepo),
      averageRating: GetAverageRatingUseCase(reviewRepo),
      create: CreateReviewUseCase(reviewRepo),
    );
    _authUseCases = (
      restore: RestoreSessionUseCase(authRepo),
      google: LoginWithGoogleUseCase(authRepo),
      logout: LogoutUseCase(authRepo),
    );
  }

  final ApiClient apiClient;

  /// Full location (description and history), which list endpoints omit.
  late final GetLocationByIdUseCase locationById;

  late final ({
    GetSavedPlansUseCase getAll,
    SavePlanUseCase save,
    DeleteSavedPlanUseCase delete,
  })
  _savedPlanUseCases;

  SavedPlansProvider createSavedPlansProvider() => SavedPlansProvider(
    getAll: _savedPlanUseCases.getAll,
    save: _savedPlanUseCases.save,
    delete: _savedPlanUseCases.delete,
  );

  /// AI visit planner ("Rencana Kunjungan").
  late final CreateTripPlanUseCase createTripPlan;
  final LocalPreferencesDataSource _prefs;
  late final PlaceCollectionRepository collections;
  late final BookmarkRepository bookmarks;
  late final OnboardingRepository onboarding;
  late final ReminderSettingsRepository reminderSettings;

  /// Agenda reminders on the device; initialised in main().
  final ReminderScheduler reminderScheduler = LocalReminderScheduler();

  AgendaRemindersProvider createAgendaRemindersProvider() =>
      AgendaRemindersProvider(
        scheduler: reminderScheduler,
        settings: reminderSettings,
      );
  final DirectionsService directions = DirectionsService();

  late final ({
    GetLocationsUseCase getLocations,
    GetLocationsByCategoryUseCase byCategory,
    SearchLocationsUseCase search,
    GetNearbyLocationsUseCase nearby,
    GetCategoriesUseCase categories,
  })
  _locationUseCases;

  late final ({
    GetReviewsForLocationUseCase getReviews,
    GetAverageRatingUseCase averageRating,
    CreateReviewUseCase create,
  })
  _reviewUseCases;

  late final ({
    RestoreSessionUseCase restore,
    LoginWithGoogleUseCase google,
    LogoutUseCase logout,
  })
  _authUseCases;

  AuthProvider createAuthProvider() => AuthProvider(
    restoreSession: _authUseCases.restore,
    loginWithGoogle: _authUseCases.google,
    logout: _authUseCases.logout,
  );

  LocationProvider createLocationProvider() => LocationProvider(
    getLocations: _locationUseCases.getLocations,
    getLocationsByCategory: _locationUseCases.byCategory,
    searchLocations: _locationUseCases.search,
    getNearbyLocations: _locationUseCases.nearby,
    getCategories: _locationUseCases.categories,
  );

  TanyaLokaProvider createTanyaLokaProvider() => TanyaLokaProvider(
    ask: AskLokaUseCase(
      AssistantRepositoryImpl(AssistantRemoteDataSource(apiClient)),
    ),
  );

  LocaleProvider createLocaleProvider() => LocaleProvider(
    _prefs,
    onLanguageChanged: (code) => apiClient.languageCode = code,
  );

  TrailProvider createTrailProvider() => TrailProvider(
    getTrails: GetTrailsUseCase(
      TrailRepositoryImpl(TrailRemoteDataSource(apiClient)),
    ),
  );

  AgendaProvider createAgendaProvider() => AgendaProvider(
    getUpcoming: GetUpcomingEventsUseCase(
      EventRepositoryImpl(EventRemoteDataSource(apiClient)),
    ),
  );

  CollectionsProvider createCollectionsProvider() => CollectionsProvider(
    repository: collections,
    loadSaved: LoadSavedPlacesUseCase(bookmarks, collections),
    toggleSaved: ToggleSavedPlaceUseCase(bookmarks),
    recordRecent: RecordRecentPlaceUseCase(collections),
  );

  ReviewProvider createReviewProvider() => ReviewProvider(
    getReviews: _reviewUseCases.getReviews,
    getAverageRating: _reviewUseCases.averageRating,
    createReview: _reviewUseCases.create,
  );
}
