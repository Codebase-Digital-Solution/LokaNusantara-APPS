import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/location.dart';
import '../../l10n/l10n.dart';
import '../providers/auth_provider.dart';
import '../providers/collections_provider.dart';
import '../providers/review_provider.dart';
import '../providers/shell_controller.dart';
import '../screens/sign_in_screen.dart';
import 'map_navigation.dart';
import '../screens/location_detail_screen.dart';
import '../widgets/dialogs.dart';
import '../widgets/review_sheet.dart';

/// Opens the Google sign-in screen. Returns true when the user signed in.
Future<bool> showAuthFlow(BuildContext context) async {
  final result = await Navigator.of(
    context,
  ).push<bool>(MaterialPageRoute(builder: (_) => const SignInScreen()));
  return result ?? false;
}

/// Opens the review sheet, asking the user to sign in first if needed.
Future<void> showReviewFlow(BuildContext context, Location location) async {
  if (!context.read<AuthProvider>().isAuthenticated) {
    final signedIn = await showAuthFlow(context);
    if (!signedIn || !context.mounted) return;
  }
  await ReviewSheet.show(
    context,
    location: location,
    onSubmit: (rating, comment) async {
      final reviews = context.read<ReviewProvider>();
      final ok = await reviews.createReview(
        locationId: location.id,
        rating: rating,
        comment: comment,
      );
      if (!ok && context.mounted) {
        await showMessageDialog(
          context,
          context.l10n.navFailed,
          reviews.error == null
              ? context.l10n.navReviewSaveFailed
              : context.l10n.errorMessage(reviews.error!),
        );
      }
      return ok;
    },
  );
}

/// Opens the detail page for [location], records it in the history and
/// handles the page's actions. [onRoute] overrides the default "open the map
/// and draw a route" behaviour.
Future<void> openLocationDetail(
  BuildContext context,
  Location location, {
  Future<void> Function()? onRoute,
}) async {
  final shell = context.read<ShellController>();
  context.read<CollectionsProvider>().recordView(location);
  final reviews = context.read<ReviewProvider>();
  if (reviews.locationId != location.id) reviews.loadForLocation(location.id);

  final action = await Navigator.of(context).push<LocationDetailAction>(
    MaterialPageRoute(
      builder: (_) => LocationDetailScreen(
        location: location,
        userLocation: shell.userLocation,
      ),
    ),
  );
  if (!context.mounted) return;

  switch (action) {
    case LocationDetailAction.route:
      if (onRoute != null) {
        await onRoute();
      } else {
        await showLocationOnMap(context, location, withRoute: true);
      }
    case LocationDetailAction.review:
      await showReviewFlow(context, location);
    case null:
      break;
  }
}
