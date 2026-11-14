import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/utils/category_style.dart';
import '../../domain/entities/location.dart';
import '../navigation/location_navigation.dart';
import '../providers/location_provider.dart';
import '../providers/trail_provider.dart';
import '../widgets/trail_carousel.dart';
import '../theme/app_colors.dart';
import '../widgets/bookmark_button.dart';
import '../widgets/category_icon.dart';
import '../widgets/masonry_grid.dart';
import '../widgets/place_image.dart';
import '../providers/agenda_provider.dart';
import 'notifications_screen.dart';

/// Image heights for the masonry tiles. Picked per location so the layout is
/// irregular but stable between rebuilds.
const _tileHeights = [168.0, 232.0, 196.0, 268.0, 150.0, 214.0, 248.0, 182.0];
const _captionHeight = 62.0;

/// How many places the home feed shows before "Lihat semua".
const homePreviewLimit = 10;

double _imageHeightFor(Location location) {
  final seed = location.id.codeUnits.fold<int>(0, (sum, c) => sum * 31 + c);
  return _tileHeights[seed.abs() % _tileHeights.length];
}

/// The regency part of an address such as "Jl. X, Ubud, Gianyar, Bali".
String _regionOf(String address) {
  final parts = [
    for (final p in address.split(','))
      if (p.trim().isNotEmpty) p.trim(),
  ];
  return parts.length >= 2 ? parts[parts.length - 2] : address;
}

/// Pinterest-style discovery feed of all locations.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String? _category;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Location> _filter(List<Location> all) {
    final q = _query.trim().toLowerCase();
    return all.where((l) {
      final matchesCategory =
          _category == null || l.category?.name.toLowerCase() == _category;
      final matchesQuery =
          q.isEmpty ||
          l.name.toLowerCase().contains(q) ||
          l.address.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void _openAll(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => AllPlacesScreen(initialCategory: _category),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocationProvider>();
    final trails = context.watch<TrailProvider>().trails;
    final matches = _filter(provider.locations);
    final searching = _query.trim().isNotEmpty;
    // Browsing shows a preview; search results are shown in full.
    final items = searching ? matches : matches.take(homePreviewLimit).toList();
    final hasMore = !searching && matches.length > items.length;
    final browsing = _query.isEmpty && _category == null;
    final showSkeleton = provider.loading && provider.locations.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.gading,
      body: RefreshIndicator(
        color: AppColors.terakota,
        onRefresh: () => Future.wait([
          provider.fetchLocations(limit: 100),
          context.read<TrailProvider>().load(),
        ]),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _Header(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            // Curated trails only while browsing, not while searching.
            if (browsing && trails.isNotEmpty)
              SliverToBoxAdapter(child: TrailCarousel(trails: trails)),
            if (!searching)
              SliverToBoxAdapter(
                child: SectionHeader(
                  icon: Icons.explore_outlined,
                  title: context.l10n.homeDestinations,
                  onSeeAll: () => _openAll(context),
                ),
              ),
            SliverToBoxAdapter(
              child: _CategoryChips(
                categories: [
                  for (final c in provider.categories) c.name.toLowerCase(),
                ],
                selected: _category,
                onSelected: (c) => setState(() => _category = c),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                16,
                4,
                16,
                24 + MediaQuery.paddingOf(context).bottom,
              ),
              sliver: SliverToBoxAdapter(
                child: showSkeleton
                    ? const _SkeletonGrid()
                    : items.isEmpty
                    ? _EmptyFeed(
                        error: provider.error == null
                            ? null
                            : context.l10n.errorMessage(provider.error!),
                        onRetry: () => provider.fetchLocations(limit: 100),
                      )
                    : Column(
                        children: [
                          _PlaceGrid(items: items, animationKey: _category),
                          if (hasMore)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () => _openAll(context),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.terakota,
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Text(
                                    context.l10n.homeSeeAllCount(
                                      matches.length,
                                    ),
                                  ),
                                ),
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

/// Masonry grid of place tiles. [animationKey] re-runs the entrance
/// animation when it changes (for example the selected category).
class _PlaceGrid extends StatelessWidget {
  const _PlaceGrid({required this.items, this.animationKey});

  final List<Location> items;
  final String? animationKey;

  @override
  Widget build(BuildContext context) {
    return MasonryGrid<Location>(
      items: items,
      heightOf: (l) => _imageHeightFor(l) + _captionHeight,
      itemBuilder: (context, location, index) => _AnimatedTile(
        key: ValueKey('${animationKey}_${location.id}'),
        index: index,
        child: _PinTile(location: location),
      ),
    );
  }
}

/// Section title with an optional "Lihat semua" link, used on the home feed.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.onSeeAll,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.terakota),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
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
    );
  }
}

/// Every place, filterable by category and searchable. Opened from
/// "Lihat semua" on the home feed with that feed's category selected.
class AllPlacesScreen extends StatefulWidget {
  const AllPlacesScreen({super.key, this.initialCategory});

  final String? initialCategory;

  @override
  State<AllPlacesScreen> createState() => _AllPlacesScreenState();
}

class _AllPlacesScreenState extends State<AllPlacesScreen> {
  late String? _category = widget.initialCategory;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocationProvider>();
    final q = _query.trim().toLowerCase();
    final items = provider.locations.where((l) {
      final inCategory =
          _category == null || l.category?.name.toLowerCase() == _category;
      final matches =
          q.isEmpty ||
          l.name.toLowerCase().contains(q) ||
          l.address.toLowerCase().contains(q);
      return inCategory && matches;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.gading,
      appBar: AppBar(
        backgroundColor: AppColors.gading,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        title: Text(
          context.l10n.homeAllDestinations,
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.terakota,
        onRefresh: () => provider.fetchLocations(limit: 100),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: context.l10n.homeSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _CategoryChips(
                categories: [
                  for (final c in provider.categories) c.name.toLowerCase(),
                ],
                selected: _category,
                onSelected: (c) => setState(() => _category = c),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  context.l10n.homeDestinationCount(items.length),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                24 + MediaQuery.paddingOf(context).bottom,
              ),
              sliver: SliverToBoxAdapter(
                child: items.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Text(
                          context.l10n.homeNoMatch,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : _PlaceGrid(items: items, animationKey: _category),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset('assets/brand/logo_mark.svg', height: 34),
                const SizedBox(width: 10),
                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Loka',
                        style: TextStyle(color: AppColors.terakota),
                      ),
                      TextSpan(
                        text: 'Nusantara',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                const _NotificationBell(),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.homeTagline,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: context.l10n.homeSearchHint,
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textMuted,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.terakota,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _Chip(
            label: context.l10n.homeCategoryAll,
            color: AppColors.sogan,
            selected: selected == null,
            onTap: () => onSelected(null),
          ),
          for (final name in categories)
            Builder(
              builder: (context) {
                final style = categoryStyleOf(name);
                return _Chip(
                  label: style == defaultCategoryStyle
                      ? name
                      : style.labelOf(context.l10n),
                  color: style.color,
                  selected: selected == name,
                  onTap: () => onSelected(name),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? color : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? color : AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinTile extends StatelessWidget {
  const _PinTile({required this.location});

  final Location location;

  @override
  Widget build(BuildContext context) {
    final style = categoryStyleOf(location.category?.name);
    return GestureDetector(
      onTap: () => openLocationDetail(context, location),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              PlaceImage(
                location: location,
                height: _imageHeightFor(location),
                borderRadius: BorderRadius.circular(18),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: BookmarkButton(location: location, size: 32),
              ),
              Positioned(
                left: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.32),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CategoryIcon(style, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        style.labelOf(context.l10n),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
            child: Text(
              location.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.25,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (location.address.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
              child: Text(
                _regionOf(location.address),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Fades and slides a tile in, staggered by its position in the feed.
class _AnimatedTile extends StatelessWidget {
  const _AnimatedTile({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final delay = (index.clamp(0, 12)) * 45;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + delay),
      curve: Interval(delay / (380 + delay), 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class _SkeletonGrid extends StatefulWidget {
  const _SkeletonGrid();

  @override
  State<_SkeletonGrid> createState() => _SkeletonGridState();
}

class _SkeletonGridState extends State<_SkeletonGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.45, end: 1.0).animate(_pulse),
      child: MasonryGrid<double>(
        items: _tileHeights,
        heightOf: (h) => h,
        itemBuilder: (_, h, _) => Container(
          height: h,
          decoration: BoxDecoration(
            color: AppColors.gadingDeep,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed({required this.error, required this.onRetry});

  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          const Icon(
            Icons.travel_explore,
            size: 56,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            error ?? context.l10n.homeNotFound,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(context.l10n.commonRetry),
            ),
          ],
        ],
      ),
    );
  }
}

/// Bell that opens upcoming agenda reminders. A dot shows when something
/// happens within the next week.
class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    final soon = context.select<AgendaProvider, int>(
      (a) => upcomingEvents(a.events, days: 7).length,
    );
    return Material(
      color: Colors.white,
      shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const NotificationsScreen())),
        child: Tooltip(
          message: context.l10n.notifTitle,
          child: SizedBox.square(
            dimension: 42,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  size: 24,
                  color: AppColors.textPrimary,
                ),
                if (soon > 0)
                  Positioned(
                    top: 9,
                    right: 10,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: AppColors.terakota,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
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
