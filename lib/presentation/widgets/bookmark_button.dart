import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/location.dart';
import '../../core/error/errors.dart';
import '../../l10n/l10n.dart';
import '../navigation/location_navigation.dart';
import '../providers/auth_provider.dart';
import '../providers/collections_provider.dart';
import '../theme/app_colors.dart';

/// Saves or unsaves [location] for the signed-in user, asking the user to
/// sign in first when needed, and reports the result in a snack bar.
Future<void> toggleBookmark(BuildContext context, Location location) async {
  final collections = context.read<CollectionsProvider>();
  final auth = context.read<AuthProvider>();
  if (!auth.isAuthenticated) {
    final signedIn = await showAuthFlow(context);
    if (!signedIn || !context.mounted) return;
    // The proxy provider also does this on the next build; doing it now
    // means the toggle below already runs as the new user.
    collections.setUser(auth.user?.id);
  }

  final l10n = context.l10n;
  String message;
  try {
    final nowSaved = await collections.toggleSaved(location);
    message = nowSaved
        ? l10n.bookmarkSaved(location.name)
        : l10n.bookmarkRemoved(location.name);
  } on AppError catch (e) {
    message = l10n.bookmarkFailed(l10n.errorMessage(e));
  }
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Text(message),
      ),
    );
}

/// Round save/unsave toggle with a small pop animation.
class BookmarkButton extends StatelessWidget {
  const BookmarkButton({
    super.key,
    required this.location,
    this.size = 34,
    this.onDark = false,
  });

  final Location location;
  final double size;

  /// Use a translucent style for placement over images and headers.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final saved = context.select<CollectionsProvider, bool>(
      (c) => c.isSaved(location.id),
    );
    return Material(
      color: onDark
          ? Colors.black.withValues(alpha: 0.28)
          : Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => toggleBookmark(context, location),
        child: SizedBox.square(
          dimension: size,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              saved ? Icons.bookmark : Icons.bookmark_border,
              key: ValueKey(saved),
              size: size * 0.55,
              color: saved
                  ? AppColors.prada
                  : (onDark ? Colors.white : AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
