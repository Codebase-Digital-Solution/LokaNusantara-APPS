import 'dart:async';

import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../core/error/errors.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/saved_plan.dart';
import '../../domain/entities/trip_plan.dart';
import '../../domain/usecases/saved_plan_usecases.dart';

/// The signed-in user's saved visit plans. Follows the account through
/// [setUser] like the saved places: signing out clears the list.
class SavedPlansProvider extends ChangeNotifier {
  /// Message of the error thrown when saving while signed out. The UI
  /// matches it to show a translated text.
  static const signInRequired = UnauthorizedError.signInToSavePlan;

  SavedPlansProvider({
    required this._getAll,
    required this._save,
    required this._delete,
  });

  final GetSavedPlansUseCase _getAll;
  final SavePlanUseCase _save;
  final DeleteSavedPlanUseCase _delete;

  List<SavedPlan> _plans = const [];
  String? _userId;
  bool _loading = false;
  AppError? _error;

  List<SavedPlan> get plans => _plans;
  bool get signedIn => _userId != null;
  bool get loading => _loading;
  AppError? get error => _error;

  /// Safe to call during a build: work and notifications run in a microtask.
  void setUser(String? userId) {
    if (userId == _userId) return;
    _userId = userId;
    _plans = const [];
    _error = null;
    if (userId == null) {
      _loading = false;
      scheduleMicrotask(notifyListeners);
      return;
    }
    _loading = true;
    scheduleMicrotask(() => _fetch(userId));
  }

  Future<void> refresh() {
    final userId = _userId;
    return userId == null ? Future.value() : _fetch(userId);
  }

  Future<void> _fetch(String userId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final list = await _getAll.execute();
      if (_userId == userId) _plans = list;
    } catch (e) {
      if (_userId == userId) _error = handleError(e);
    } finally {
      if (_userId == userId) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  /// Saves [plan] for the signed-in user and puts it first in the list.
  /// Throws [AppError] when signed out or on failure.
  Future<SavedPlan> save(Location location, TripPlan plan) async {
    if (_userId == null) {
      throw const UnauthorizedError(signInRequired);
    }
    try {
      final saved = await _save.execute(location, plan);
      _plans = [saved, ..._plans];
      notifyListeners();
      return saved;
    } catch (e) {
      throw handleError(e);
    }
  }

  /// Removes the plan right away and restores it if the server call fails.
  Future<void> delete(int id) async {
    final before = _plans;
    _plans = _plans.where((p) => p.id != id).toList();
    notifyListeners();
    try {
      await _delete.execute(id);
    } catch (e) {
      _plans = before;
      notifyListeners();
      throw handleError(e);
    }
  }
}
