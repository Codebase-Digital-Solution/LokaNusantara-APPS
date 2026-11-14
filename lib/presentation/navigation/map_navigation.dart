import 'package:flutter/material.dart';

import '../../domain/entities/location.dart';
import '../../domain/entities/trail.dart';
import '../screens/map_screen.dart';

/// What the map should show when it opens.
class MapFocusRequest {
  const MapFocusRequest(this.location, {this.withRoute = false}) : trail = null;

  const MapFocusRequest.trail(Trail this.trail)
    : location = null,
      withRoute = false;

  final Location? location;
  final bool withRoute;

  /// When set, the map shows this whole trail instead of one location.
  final Trail? trail;
}

/// Opens the map as its own full-screen page. Closing it returns to the page
/// it was opened from.
Future<void> openMap(BuildContext context, {MapFocusRequest? request}) {
  return Navigator.of(context).push(
    PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, _, _) => MapScreen(request: request),
      transitionsBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        // Grows out of the bottom centre, where the map button sits.
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            alignment: Alignment.bottomCenter,
            scale: Tween(begin: 0.92, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
}

/// Opens the map focused on [location], optionally drawing a route to it.
Future<void> showLocationOnMap(
  BuildContext context,
  Location location, {
  bool withRoute = false,
}) =>
    openMap(context, request: MapFocusRequest(location, withRoute: withRoute));

/// Opens the map with a whole trail drawn on it.
Future<void> showTrailOnMap(BuildContext context, Trail trail) =>
    openMap(context, request: MapFocusRequest.trail(trail));
