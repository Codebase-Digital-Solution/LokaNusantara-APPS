import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';

import '../../core/utils/category_style.dart';
import '../../core/utils/color_hex.dart';
import '../../domain/entities/trail.dart';
import '../../domain/usecases/trail_usecases.dart';
import '../navigation/location_navigation.dart';
import '../navigation/map_navigation.dart';
import '../theme/app_colors.dart';
import '../widgets/category_icon.dart';
import '../widgets/cover_photo.dart';
import '../widgets/kawung_pattern.dart';
import '../widgets/place_image.dart';

/// Story and ordered stops of one Jalur Kisah, with a button to draw it on
/// the map.
class TrailDetailScreen extends StatelessWidget {
  const TrailDetailScreen({super.key, required this.trail});

  final Trail trail;

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(trail.colorHex, fallback: AppColors.terakota);
    final km = trailDistanceKm(trail);

    return Scaffold(
      backgroundColor: AppColors.gading,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: trail.imageUrl == null ? 240 : 280,
            backgroundColor: color,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(
                start: 56,
                end: 16,
                bottom: 14,
              ),
              title: Text(
                trail.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [color, AppColors.sogan],
                      ),
                    ),
                  ),
                  const KawungPattern(color: Color(0x1FFFFFFF), tileSize: 64),
                  if (trail.imageUrl != null) CoverPhoto(url: trail.imageUrl!),
                  Positioned(
                    left: 16,
                    bottom: 64,
                    right: 16,
                    child: Text(
                      trail.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      _Stat(
                        icon: Icons.place_outlined,
                        text: context.l10n.trailStopCount(trail.stops.length),
                        color: color,
                      ),
                      const SizedBox(width: 10),
                      _Stat(
                        icon: Icons.route_outlined,
                        text: context.l10n.trailAboutKm(km.round()),
                        color: color,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_stories_outlined,
                              size: 20,
                              color: AppColors.prada,
                            ),
                            SizedBox(width: 8),
                            Text(
                              context.l10n.trailStory,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          trail.story,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.l10n.trailStops,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList.builder(
              itemCount: trail.stops.length,
              itemBuilder: (context, i) => _StopTile(
                stop: trail.stops[i],
                color: color,
                isLast: i == trail.stops.length - 1,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          12 + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 10)],
        ),
        child: FilledButton.icon(
          // Closing the map comes back to this trail.
          onPressed: () => showTrailOnMap(context, trail),
          icon: const Icon(Icons.map_outlined),
          label: Text(context.l10n.trailShowOnMap),
          style: FilledButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// One numbered stop with a connector line to the next.
class _StopTile extends StatelessWidget {
  const _StopTile({
    required this.stop,
    required this.color,
    required this.isLast,
  });

  final TrailStop stop;
  final Color color;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final style = categoryStyleOf(stop.location.category?.name);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Text(
                    '${stop.position}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 3,
                      color: color.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => openLocationDetail(context, stop.location),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PlaceImage(
                        location: stop.location,
                        height: 110,
                        compact: true,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CategoryIcon(
                                  style,
                                  size: 14,
                                  color: style.color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  style.labelOf(context.l10n),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: style.color,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stop.location.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (stop.note.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                stop.note,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.45,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
