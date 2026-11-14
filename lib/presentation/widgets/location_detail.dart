import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:latlong2/latlong.dart';

import '../../core/utils/category_style.dart';
import '../../core/utils/directions.dart';
import '../../core/utils/helpers.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/review.dart';
import '../theme/app_colors.dart';

class LocationDetail extends StatelessWidget {
  const LocationDetail({
    super.key,
    required this.location,
    required this.reviews,
    required this.averageRating,
    required this.loading,
    required this.userLocation,
    required this.transportMode,
    required this.routeLoading,
    required this.onRoutePress,
    required this.onReviewPress,
    required this.onClosePress,
    required this.onOpenDetail,
  });

  final Location location;
  final List<Review> reviews;
  final double averageRating;
  final bool loading;
  final LatLng? userLocation;
  final TransportMode transportMode;
  final bool routeLoading;
  final ValueChanged<TransportMode> onRoutePress;
  final VoidCallback onReviewPress;
  final VoidCallback onClosePress;

  /// Opens the full page with history, etiquette and all reviews.
  final VoidCallback onOpenDetail;

  static const _modes = [
    (mode: TransportMode.driving, icon: Icons.directions_car),
    (mode: TransportMode.walking, icon: Icons.directions_walk),
    (mode: TransportMode.cycling, icon: Icons.directions_bike),
  ];

  static String _modeLabel(AppLocalizations l10n, TransportMode mode) =>
      switch (mode) {
        TransportMode.driving => l10n.detailModeCar,
        TransportMode.walking => l10n.detailModeWalk,
        TransportMode.cycling => l10n.detailModeBike,
      };

  @override
  Widget build(BuildContext context) {
    final user = userLocation;
    final distance = user == null
        ? null
        : formatDistance(
            calculateDistance(
              user.latitude,
              user.longitude,
              location.latitude,
              location.longitude,
            ),
          );
    final style = categoryStyleOf(location.category?.name);
    final routeColor = style.color;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        20,
        16,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Color(0x26000000), blurRadius: 12)],
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 40, bottom: 12),
                        child: GestureDetector(
                          onTap: onOpenDetail,
                          child: Text(
                            location.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      _InfoRow(
                        context.l10n.detailCategory,
                        style.labelOf(context.l10n),
                      ),
                      if (distance != null)
                        _InfoRow(context.l10n.detailDistance, distance),
                      _InfoRow(
                        context.l10n.detailRating,
                        averageRating > 0
                            ? averageRating.toStringAsFixed(1)
                            : context.l10n.detailNoRating,
                        leading: averageRating > 0
                            ? const Icon(
                                Icons.star,
                                size: 16,
                                color: AppColors.prada,
                              )
                            : null,
                      ),
                      if (location.description.isNotEmpty)
                        _Section(
                          context.l10n.detailDescription,
                          location.description,
                        ),
                      if (location.history.isNotEmpty)
                        _HistoryTeaser(
                          text: location.history,
                          onTap: onOpenDetail,
                        ),
                      if (location.address.isNotEmpty)
                        _Section(context.l10n.detailAddress, location.address),
                      if (reviews.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          context.l10n.detailLatestReviews,
                          style: _sectionTitle,
                        ),
                        const SizedBox(height: 8),
                        for (final review in reviews.take(3))
                          _ReviewTile(review: review),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onOpenDetail,
                icon: const Icon(Icons.auto_stories_outlined, size: 18),
                label: Text(context.l10n.detailFullHistory),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.terakota,
                  backgroundColor: AppColors.gading,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final m in _modes) ...[
                    Expanded(
                      child: _RouteButton(
                        icon: m.icon,
                        label: _modeLabel(context.l10n, m.mode),
                        color: routeColor,
                        active: transportMode == m.mode,
                        loading: routeLoading && transportMode == m.mode,
                        enabled: !routeLoading && userLocation != null,
                        onTap: () => onRoutePress(m.mode),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: loading ? null : onReviewPress,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.terakota,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: loading
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                context.l10n.detailReviews,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: -8,
            right: 0,
            child: Material(
              color: const Color(0xFFF3F4F6),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onClosePress,
                child: const SizedBox.square(
                  dimension: 32,
                  child: Icon(Icons.close, size: 18, color: Color(0xFF6B7280)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _sectionTitle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w700,
  color: Color(0xFF1F2937),
);

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {this.leading});

  final String label;
  final String value;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const Spacer(),
          if (leading != null) ...[leading!, const SizedBox(width: 4)],
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.body);

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _sectionTitle),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                Icon(
                  Icons.star,
                  size: 14,
                  color: i <= review.rating
                      ? AppColors.prada
                      : const Color(0xFFD1D5DB),
                ),
              if (review.user != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    review.user!.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              review.comment,
              style: const TextStyle(
                fontSize: 12,
                height: 1.35,
                color: Color(0xFF4B5563),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RouteButton extends StatelessWidget {
  const _RouteButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.active,
    required this.loading,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool active;
  final bool loading;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = active ? Colors.white : color;
    return Opacity(
      opacity: enabled || loading ? 1 : 0.5,
      child: Material(
        color: active ? color : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color, width: 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: enabled ? onTap : null,
          child: SizedBox(
            height: 52,
            child: Center(
              child: loading
                  ? SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: fg,
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 16, color: fg),
                        const SizedBox(height: 3),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: fg,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Three-line preview of the history text; tapping opens the detail page.
class _HistoryTeaser extends StatelessWidget {
  const _HistoryTeaser({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: AppColors.gading,
          borderRadius: BorderRadius.circular(10),
          border: const Border(
            left: BorderSide(color: AppColors.prada, width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_stories_outlined,
                  size: 16,
                  color: AppColors.terakota,
                ),
                const SizedBox(width: 6),
                Text(context.l10n.detailHistory, style: _sectionTitle),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.detailReadMore,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.terakota,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
