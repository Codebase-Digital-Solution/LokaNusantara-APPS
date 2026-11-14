import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../core/error/errors.dart';
import '../../domain/entities/trail.dart';
import '../../domain/usecases/trail_usecases.dart';

class TrailProvider extends ChangeNotifier {
  TrailProvider({required this._getTrails});

  final GetTrailsUseCase _getTrails;

  List<Trail> _trails = const [];
  bool _loading = false;
  AppError? _error;

  List<Trail> get trails => _trails;
  bool get loading => _loading;
  AppError? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _trails = await _getTrails.execute();
    } catch (e) {
      _error = handleError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
