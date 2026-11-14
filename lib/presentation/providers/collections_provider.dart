import 'dart:async';

import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../core/error/errors.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/place_collection_repository.dart';
import '../../domain/usecases/collection_usecases.dart';

/// Saved places (per account, on the server) and the recently viewed
/// history (on the device). Follows the signed-in user through [setUser]:
/// signing in loads that account's saved places, signing out clears both
/// lists from memory and the device.
class CollectionsProvider extends ChangeNotifier {
  /// Message of the error thrown when saving while signed out. The UI
  /// matches it to show a translated text.
  static const signInRequired = UnauthorizedError.signInToSavePlace;

  CollectionsProvider({
    required this._repository,
    required this._loadSaved,
    required this._toggleSaved,
    required this._recordRecent,
  });

  final PlaceCollectionRepository _repository;
  final LoadSavedPlacesUseCase _loadSaved;
  final ToggleSavedPlaceUseCase _toggleSaved;
  final RecordRecentPlaceUseCase _recordRecent;

  List<Location> _saved = const [];
  List<Location> _recent = const [];
  bool _loaded = false;
  String? _userId;
  bool _savedLoading = false;
  AppError? _savedError;
  Future<void>? _savedLoad;

  List<Location> get saved => _saved;
  List<Location> get recent => _recent;
  bool get loaded => _loaded;
  bool get signedIn => _userId != null;
  bool get savedLoading => _savedLoading;
  AppError? get savedError => _savedError;

  bool isSaved(String id) => _saved.any((p) => p.id == id);

  /// Loads the recently viewed history from the device.
  Future<void> load() async {
    _recent = await _repository.getRecent();
    _loaded = true;
    notifyListeners();
  }

  /// Called whenever the signed-in user changes (null when signed out).
  /// Safe to call during a build: listeners are notified in a microtask.
  void setUser(String? userId) {
    if (userId == _userId) return;
    final hadUser = _userId != null;
    _userId = userId;
    _saved = const [];
    _savedError = null;

    // Signing out or switching accounts: the history belonged to the
    // previous person, so it leaves the device too.
    if (hadUser) {
      _recent = const [];
      unawaited(_repository.setRecent(const []));
    }

    if (userId == null) {
      _savedLoad = null;
      _savedLoading = false;
      scheduleMicrotask(notifyListeners);
      return;
    }
    _savedLoading = true;
    _savedLoad = Future.microtask(() => _fetchSaved(userId));
  }

  /// Reloads saved places from the server, for pull-to-refresh or retry.
  Future<void> refreshSaved() {
    final userId = _userId;
    if (userId == null) return Future.value();
    return _savedLoad = _fetchSaved(userId);
  }

  Future<void> _fetchSaved(String userId) async {
    _savedLoading = true;
    _savedError = null;
    notifyListeners();
    try {
      final list = await _loadSaved.execute();
      if (_userId == userId) _saved = list;
    } catch (e) {
      if (_userId == userId) _savedError = handleError(e);
    } finally {
      if (_userId == userId) {
        _savedLoading = false;
        notifyListeners();
      }
    }
  }

  /// Saves or unsaves [place] for the signed-in user. Updates the list right
  /// away and rolls back if the server call fails. Returns true when the
  /// place is saved afterwards. Throws [AppError] when signed out or on
  /// failure.
  Future<bool> toggleSaved(Location place) async {
    if (_userId == null) {
      throw const UnauthorizedError(signInRequired);
    }
    // Let a pending load finish first so it cannot overwrite this change.
    await _savedLoad;

    final wasSaved = isSaved(place.id);
    final before = _saved;
    _saved = wasSaved
        ? _saved.where((p) => p.id != place.id).toList()
        : [place, ..._saved];
    notifyListeners();
    try {
      await _toggleSaved.execute(place, save: !wasSaved);
    } catch (e) {
      _saved = before;
      notifyListeners();
      throw handleError(e);
    }
    return !wasSaved;
  }

  Future<void> recordView(Location place) async {
    _recent = await _recordRecent.execute(_recent, place);
    notifyListeners();
  }

  Future<void> clearRecent() async {
    await _repository.setRecent(const []);
    _recent = const [];
    notifyListeners();
  }
}
