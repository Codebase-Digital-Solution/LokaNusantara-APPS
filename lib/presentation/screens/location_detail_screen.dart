import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/audio/flutter_tts_engine.dart';
import '../../core/audio/speech_engine.dart';
import '../../core/utils/category_style.dart';
import '../../core/utils/helpers.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/review.dart';
import '../../domain/usecases/location_usecases.dart';
import '../providers/audio_guide.dart';
import '../providers/review_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/category_icon.dart';
import '../widgets/cover_photo.dart';
import '../widgets/kawung_pattern.dart';
import '../widgets/audio_guide_card.dart';
import '../widgets/bookmark_button.dart';
import '../widgets/plan_sheet.dart';
import 'tanya_loka_screen.dart';

/// What the user chose to do from the detail page; handled by the map.
enum LocationDetailAction { route, review }

/// Full page for one location: overview, history, visiting etiquette,
/// address and reviews.
class LocationDetailScreen extends StatefulWidget {
  const LocationDetailScreen({
    super.key,
    required this.location,
    this.userLocation,
    this.speechEngine = _defaultEngine,
  });

  final Location location;
  final LatLng? userLocation;

  /// Creates the text-to-speech engine for the audio guide; replaceable in
  /// tests.
  final SpeechEngine Function() speechEngine;

  static SpeechEngine _defaultEngine() => FlutterTtsEngine();

  @override
  State<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

/// List endpoints omit description and history to stay light, so the page
/// fetches the full record when they are missing.
class _LocationDetailScreenState extends State<LocationDetailScreen> {
  late Location _location = widget.location;

  @override
  void initState() {
    super.initState();
    if (_location.description.isEmpty && _location.history.isEmpty) {
      _loadDetails();
    }
  }

  Future<void> _loadDetails() async {
    final useCase = Provider.of<GetLocationByIdUseCase?>(
      context,
      listen: false,
    );
    if (useCase == null) return;
    try {
      final full = await useCase.execute(_location.id);
      if (mounted) setState(() => _location = full);
    } catch (e) {
      debugPrint('[LocationDetail] could not load details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keyed so the audio guide is rebuilt with the full narration.
    return _LocationDetailView(
      key: ValueKey(_location.history.length + _location.description.length),
      location: _location,
      userLocation: widget.userLocation,
      speechEngine: widget.speechEngine,
    );
  }
}

class _LocationDetailView extends StatelessWidget {
  const _LocationDetailView({
    super.key,
    required this.location,
    this.userLocation,
    required this.speechEngine,
  });

  final Location location;
  final LatLng? userLocation;
  final SpeechEngine Function() speechEngine;

  @override
  Widget build(BuildContext context) {
    final style = categoryStyleOf(location.category?.name);
    final reviews = context.watch<ReviewProvider>();
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

    // Owned by this page: leaving the page disposes it and stops the voice.
    return ChangeNotifierProvider(
      create: (_) => AudioGuide(
        segments: narrationFor(location),
        createEngine: speechEngine,
      ),
      child: Scaffold(
        backgroundColor: AppColors.gading,
        body: CustomScrollView(
          slivers: [
            _Header(location: location, style: style),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _StatsRow(
                      style: style,
                      distance: distance,
                      rating: reviews.averageRating,
                      reviewCount: reviews.reviews.length,
                    ),
                    AudioGuideCard(color: style.color),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: FilledButton(
                        onPressed: () => showPlanSheet(context, location),
                        style: FilledButton.styleFrom(
                          backgroundColor: style.color,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(context.l10n.detailMakePlan),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: OutlinedButton(
                        onPressed: () => openTanyaLokaAbout(context, location),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.sogan,
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(context.l10n.detailAskLoka),
                      ),
                    ),
                    if (location.description.isNotEmpty)
                      _SectionCard(
                        icon: Icons.info_outline,
                        title: context.l10n.detailAbout,
                        child: _BodyText(location.description),
                      ),
                    _SectionCard(
                      icon: Icons.auto_stories_outlined,
                      title: context.l10n.detailHistory,
                      accent: AppColors.prada,
                      child: location.history.isEmpty
                          ? _BodyText(
                              context.l10n.detailHistoryEmpty,
                              muted: true,
                            )
                          : _HistoryText(location.history),
                    ),
                    _SectionCard(
                      icon: Icons.volunteer_activism_outlined,
                      title: context.l10n.detailEtiquette,
                      child: Column(
                        children: [
                          for (final tip in style.etiquetteOf(context.l10n))
                            _Bullet(text: tip, color: style.color),
                        ],
                      ),
                    ),
                    if (location.address.isNotEmpty)
                      _SectionCard(
                        icon: Icons.place_outlined,
                        title: context.l10n.detailAddress,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _BodyText(location.address),
                            const SizedBox(height: 4),
                            Text(
                              '${location.latitude.toStringAsFixed(5)}, '
                              '${location.longitude.toStringAsFixed(5)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    _SectionCard(
                      icon: Icons.rate_review_outlined,
                      title: context.l10n.detailReviews,
                      child: reviews.loading && reviews.reviews.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : reviews.reviews.isEmpty
                          ? _BodyText(
                              context.l10n.detailReviewsEmpty,
                              muted: true,
                            )
                          : Column(
                              children: [
                                for (final review in reviews.reviews)
                                  _ReviewTile(review: review),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _ActionBar(
          color: style.color,
          canRoute: userLocation != null,
        ),
      ),
    );
  }
}

/// Full-screen photo with pinch to zoom.
void _openPhoto(BuildContext context, String url) {
  Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black,
      pageBuilder: (context, _, _) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: Center(
          child: InteractiveViewer(
            maxScale: 4,
            child: Image.network(
              url,
              headers: ApiClient.mediaHeaders,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.broken_image_outlined,
                color: Colors.white54,
                size: 48,
              ),
            ),
          ),
        ),
      ),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.location, required this.style});

  final Location location;
  final CategoryStyle style;

  @override
  Widget build(BuildContext context) {
    final imageUrl = location.imageUrl;
    return SliverAppBar(
      pinned: true,
      expandedHeight: imageUrl == null ? 260 : 300,
      backgroundColor: style.color,
      foregroundColor: Colors.white,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: BookmarkButton(location: location, onDark: true),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(
          start: 56,
          end: 16,
          bottom: 14,
        ),
        title: Text(
          location.name,
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
                  colors: [style.color, AppColors.sogan],
                ),
              ),
            ),
            const KawungPattern(color: Color(0x1FFFFFFF), tileSize: 64),
            if (imageUrl == null)
              Positioned(
                right: -24,
                bottom: -12,
                child: CategoryIcon(
                  style,
                  size: 190,
                  color: Colors.white.withValues(alpha: 0.14),
                ),
              )
            else
              // Fades in over the category backdrop, which stays visible
              // while loading or if the photo fails.
              CoverPhoto(
                url: imageUrl,
                heroTag: 'place-photo-${location.id}',
                onTap: () => _openPhoto(context, imageUrl),
              ),
            Positioned(
              left: 16,
              bottom: 64,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CategoryIcon(style, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      style == defaultCategoryStyle
                          ? (location.category?.name ??
                                style.labelOf(context.l10n))
                          : style.labelOf(context.l10n),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.style,
    required this.distance,
    required this.rating,
    required this.reviewCount,
  });

  final CategoryStyle style;
  final String? distance;
  final double rating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Stat(
            icon: Icons.star_rounded,
            iconColor: AppColors.prada,
            value: rating > 0 ? rating.toStringAsFixed(1) : '-',
            label: reviewCount > 0
                ? context.l10n.detailReviewCount(reviewCount)
                : context.l10n.detailNotRated,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Stat(
            icon: Icons.near_me_outlined,
            iconColor: AppColors.nila,
            value: distance ?? '-',
            label: context.l10n.detailDistance,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Stat(
            iconWidget: CategoryIcon(style, size: 20, color: style.color),
            value: style.labelOf(context.l10n),
            label: context.l10n.detailCategory,
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
    this.iconWidget,
  });

  final IconData? icon;
  final Color? iconColor;
  final Widget? iconWidget;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          iconWidget ?? Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.accent = AppColors.terakota,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: accent),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText(this.text, {this.muted = false});

  final String text;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        height: 1.55,
        color: muted ? AppColors.textMuted : AppColors.textSecondary,
        fontStyle: muted ? FontStyle.italic : FontStyle.normal,
      ),
    );
  }
}

/// History text with a gold rule on the left and a drop-cap first letter.
class _HistoryText extends StatelessWidget {
  const _HistoryText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    const body = TextStyle(
      fontSize: 14.5,
      height: 1.65,
      color: AppColors.textSecondary,
    );
    // Highlight the sentence the audio guide is reading.
    final active = context.select<AudioGuide, int?>(
      (g) => g.activeHistorySentence,
    );
    final sentences = splitSentences(text);
    final highlight = body.copyWith(
      color: AppColors.textPrimary,
      backgroundColor: AppColors.pradaLight.withValues(alpha: 0.55),
    );

    return Container(
      padding: const EdgeInsets.only(left: 12),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.prada, width: 3)),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            for (var i = 0; i < sentences.length; i++) ...[
              if (i == 0) ...[
                TextSpan(
                  text: sentences[0].substring(0, 1),
                  style: const TextStyle(
                    fontSize: 30,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: AppColors.terakota,
                  ),
                ),
                TextSpan(
                  text: sentences[0].substring(1),
                  style: active == 0 ? highlight : body,
                ),
              ] else
                TextSpan(
                  text: sentences[i],
                  style: active == i ? highlight : body,
                ),
              if (i < sentences.length - 1) const TextSpan(text: ' '),
            ],
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: i <= review.rating
                      ? AppColors.prada
                      : const Color(0xFFE2D6C2),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  review.user?.name ?? context.l10n.detailVisitor,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              review.comment,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.color, required this.canRoute});

  final Color color;
  final bool canRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () =>
                  Navigator.of(context).pop(LocationDetailAction.review),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(context.l10n.reviewWrite),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.terakota,
                side: const BorderSide(color: AppColors.terakota),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: canRoute
                  ? () => Navigator.of(context).pop(LocationDetailAction.route)
                  : null,
              icon: const Icon(Icons.directions, size: 18),
              label: Text(context.l10n.detailRoute),
              style: FilledButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
