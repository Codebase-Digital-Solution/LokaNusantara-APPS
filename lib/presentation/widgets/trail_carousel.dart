import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';

import '../../core/utils/category_style.dart';
import '../../core/utils/color_hex.dart';
import '../../domain/entities/trail.dart';
import '../screens/trail_detail_screen.dart';
import '../theme/app_colors.dart';
import 'category_icon.dart';
import 'cover_photo.dart';
import 'kawung_pattern.dart';

/// Horizontal "Jalur Kisah" cards shown at the top of the home feed.
class TrailCarousel extends StatelessWidget {
  const TrailCarousel({super.key, required this.trails});

  final List<Trail> trails;

  /// How many trails the carousel shows before "Lihat semua".
  static const previewLimit = 10;

  @override
  Widget build(BuildContext context) {
    final preview = trails.take(previewLimit).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 6),
          child: Row(
            children: [
              const Icon(
                Icons.route_outlined,
                size: 20,
                color: AppColors.terakota,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  context.l10n.trailTitle,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AllTrailsScreen(trails: trails),
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.terakota,
                  textStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(context.l10n.commonSeeAll),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: preview.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) => TrailCard(trail: preview[i]),
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

/// One Jalur Kisah card. [width] is fixed in the carousel; null fills the
/// available width (the "Lihat semua" list).
class TrailCard extends StatelessWidget {
  const TrailCard({super.key, required this.trail, this.width = 250});

  final Trail trail;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(trail.colorHex, fallback: AppColors.terakota);
    // Up to four category glyphs hint at what the trail passes through.
    final styles = <CategoryStyle>{
      for (final s in trail.stops) categoryStyleOf(s.location.category?.name),
    }.take(4);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TrailDetailScreen(trail: trail)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: width,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, AppColors.sogan],
              ),
            ),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: KawungPattern(color: Color(0x1AFFFFFF), tileSize: 48),
                ),
                if (trail.imageUrl != null)
                  Positioned.fill(child: CoverPhoto(url: trail.imageUrl!)),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          for (final style in styles)
                            Container(
                              width: 28,
                              height: 28,
                              margin: const EdgeInsets.only(right: 6),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: CategoryIcon(style, size: 15),
                            ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        trail.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.trailStopCount(trail.stops.length),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Every Jalur Kisah as full-width cards.
class AllTrailsScreen extends StatelessWidget {
  const AllTrailsScreen({super.key, required this.trails});

  final List<Trail> trails;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gading,
      appBar: AppBar(
        backgroundColor: AppColors.gading,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        title: Text(
          context.l10n.trailTitle,
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          16,
          4,
          16,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        itemCount: trails.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) => SizedBox(
          height: 180,
          child: TrailCard(trail: trails[i], width: null),
        ),
      ),
    );
  }
}
