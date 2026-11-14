import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../core/error/errors.dart';
import '../../domain/entities/cultural_event.dart';
import '../../domain/usecases/event_usecases.dart';

class AgendaProvider extends ChangeNotifier {
  AgendaProvider({required this._getUpcoming});

  final GetUpcomingEventsUseCase _getUpcoming;

  List<CulturalEvent> _events = const [];
  bool _loading = false;
  bool _loaded = false;
  AppError? _error;

  List<CulturalEvent> get events => _events;
  bool get loading => _loading;
  bool get loaded => _loaded;
  AppError? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _events = await _getUpcoming.execute();
      _loaded = true;
    } catch (e) {
      _error = handleError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
