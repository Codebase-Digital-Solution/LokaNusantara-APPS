import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:latlong2/latlong.dart';

/// Tabs of the bottom-navigation shell. The map is not a tab: it opens as
/// its own page (see `openMap`).
enum ShellTab { home, saved, agenda, profile }

/// Coordinates the bottom-navigation shell: the active tab and the last
/// known user position.
class ShellController extends ChangeNotifier {
  ShellTab _tab = ShellTab.home;

  ShellTab get tab => _tab;

  /// Last GPS fix, written by the map as positions arrive. Not observable:
  /// readers fetch it when they need it.
  LatLng? userLocation;

  void goTo(ShellTab tab) {
    if (_tab == tab) return;
    _tab = tab;
    notifyListeners();
  }
}
