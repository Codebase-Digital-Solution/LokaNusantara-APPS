import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:provider/provider.dart';

import '../../core/utils/currency_format.dart';
import '../../core/utils/date_format.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/saved_plan.dart';
import '../navigation/location_navigation.dart';
import '../providers/collections_provider.dart';
import '../providers/saved_plans_provider.dart';
import '../providers/shell_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/bookmark_button.dart';
import '../widgets/dialogs.dart';
import '../widgets/kawung_pattern.dart';
import '../widgets/place_image.dart';
import '../widgets/place_list_card.dart';
import 'plan_result_screen.dart';

/// Saved places and saved visit plans, as two tabs. Both live in the
/// signed-in account.
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final collections = context.watch<CollectionsProvider>();
    final planCount = context.select<SavedPlansProvider, int>(
      (p) => p.plans.length,
    );
    final signedIn = collections.signedIn;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.gading,
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: _CollectionHeader(
                title: l10n.savedTitle,
                subtitle: signedIn
                    ? l10n.savedSubtitle(collections.saved.length, planCount)
                    : l10n.savedSubtitleSignedOut,
                action: signedIn
                    ? null
                    : TextButton(
                        onPressed: () => showAuthFlow(context),
                        child: Text(
                          l10n.authSignIn,
                          style: const TextStyle(
                            color: AppColors.terakota,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.gadingDeep,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(color: Color(0x14000000), blurRadius: 4),
                  ],
                ),
                labelColor: AppColors.terakota,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
                tabs: [
                  Tab(height: 38, text: l10n.savedTabPlaces),
                  Tab(height: 38, text: l10n.savedTabPlans),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [_SavedPlacesTab(), _SavedPlansTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedPlacesTab extends StatelessWidget {
  const _SavedPlacesTab();

  @override
  Widget build(BuildContext context) {
    final collections = context.watch<CollectionsProvider>();
    final signedIn = collections.signedIn;
    final failed = collections.savedError != null && collections.saved.isEmpty;
    final l10n = context.l10n;
    return _PlaceListView(
      icon: Icons.bookmark_rounded,
      places: collections.saved,
      loading: collections.savedLoading && collections.saved.isEmpty,
      onRefresh: signedIn ? collections.refreshSaved : null,
      emptyTitle: !signedIn
          ? l10n.savedPlacesSignInTitle
          : failed
          ? l10n.savedPlacesFailed
          : l10n.savedPlacesEmpty,
      emptyBody: !signedIn
          ? l10n.savedPlacesSignInBody
          : failed
          ? l10n.savedPullToRetry(l10n.errorMessage(collections.savedError!))
          : l10n.savedPlacesEmptyBody,
      trailingFor: (place) => IconButton(
        tooltip: l10n.savedRemove,
        icon: const Icon(Icons.bookmark, color: AppColors.prada),
        onPressed: () => toggleBookmark(context, place),
      ),
    );
  }
}

class _SavedPlansTab extends StatelessWidget {
  const _SavedPlansTab();

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<SavedPlansProvider>();
    final failed = saved.error != null && saved.plans.isEmpty;
    final l10n = context.l10n;

    final Widget body;
    if (saved.loading && saved.plans.isEmpty) {
      body = const _FillScroll(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.terakota),
        ),
      );
    } else if (saved.plans.isEmpty) {
      body = _FillScroll(
        child: _EmptyState(
          icon: Icons.event_available_rounded,
          title: !saved.signedIn
              ? l10n.savedPlansSignInTitle
              : failed
              ? l10n.savedPlansFailed
              : l10n.savedPlansEmpty,
          body: !saved.signedIn
              ? l10n.savedPlansSignInBody
              : failed
              ? l10n.savedPullToRetry(l10n.errorMessage(saved.error!))
              : l10n.savedPlansEmptyBody,
        ),
      );
    } else {
      body = ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          16,
          4,
          16,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        itemCount: saved.plans.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _SavedPlanCard(saved: saved.plans[i]),
      );
    }
    return saved.signedIn
        ? RefreshIndicator(
            color: AppColors.terakota,
            onRefresh: saved.refresh,
            child: body,
          )
        : body;
  }
}

class _SavedPlanCard extends StatelessWidget {
  const _SavedPlanCard({required this.saved});
  final SavedPlan saved;

  @override
  Widget build(BuildContext context) {
    final plan = saved.plan;
    final ok = plan.withinBudget;
    final status = ok ? const Color(0xFF1F7A5C) : const Color(0xFFB4630C);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PlanResultScreen(
              location: saved.location,
              plan: plan,
              savedId: saved.id,
            ),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: PlaceImage(
                  location: saved.location,
                  height: 64,
                  borderRadius: BorderRadius.circular(12),
                  compact: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      saved.location.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      context.l10n.savedPlanMeta(
                        plan.people,
                        plan.days,
                        formatRupiah(plan.totalEstimate),
                      ),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          ok
                              ? Icons.check_circle_rounded
                              : Icons.warning_amber_rounded,
                          size: 14,
                          color: status,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ok
                              ? context.l10n.savedWithinBudget
                              : context.l10n.savedOverBudget,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: status,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          mediumDate(saved.createdAt, context.l10n),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lets an empty or loading tab still be pulled to refresh.
class _FillScroll extends StatelessWidget {
  const _FillScroll({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    slivers: [SliverFillRemaining(hasScrollBody: false, child: child)],
  );
}

/// Recently viewed destinations, newest first.
class RecentScreen extends StatelessWidget {
  const RecentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final collections = context.watch<CollectionsProvider>();
    final l10n = context.l10n;
    return _CollectionScaffold(
      title: l10n.recentTitle,
      subtitle: l10n.recentSubtitle,
      icon: Icons.history_rounded,
      places: collections.recent,
      emptyTitle: l10n.recentEmptyTitle,
      emptyBody: l10n.recentEmptyBody,
      action: collections.recent.isEmpty
          ? null
          : IconButton(
              tooltip: l10n.recentClear,
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () async {
                final ok = await showConfirmDialog(
                  context,
                  title: l10n.recentClear,
                  message: l10n.recentClearMessage,
                  confirmLabel: l10n.recentClearConfirm,
                  destructive: true,
                );
                if (ok) await collections.clearRecent();
              },
            ),
      trailingFor: (_) =>
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
    );
  }
}

/// A pushed page (Riwayat) with a header and a list of places.
class _CollectionScaffold extends StatelessWidget {
  const _CollectionScaffold({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.places,
    required this.emptyTitle,
    required this.emptyBody,
    required this.trailingFor,
    this.action,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Location> places;
  final String emptyTitle;
  final String emptyBody;
  final Widget Function(Location place) trailingFor;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gading,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: _CollectionHeader(
              title: title,
              subtitle: subtitle,
              action: action,
            ),
          ),
          Expanded(
            child: _PlaceListView(
              icon: icon,
              places: places,
              emptyTitle: emptyTitle,
              emptyBody: emptyBody,
              trailingFor: trailingFor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionHeader extends StatelessWidget {
  const _CollectionHeader({
    required this.title,
    required this.subtitle,
    this.action,
  });

  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
      child: Row(
        children: [
          // Riwayat is pushed from Profil, so it needs a way back.
          if (ModalRoute.of(context)?.canPop ?? false) ...[
            const BackButton(color: AppColors.textPrimary),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// Places list with loading and empty states, optionally pull-to-refresh.
class _PlaceListView extends StatelessWidget {
  const _PlaceListView({
    required this.icon,
    required this.places,
    required this.emptyTitle,
    required this.emptyBody,
    required this.trailingFor,
    this.loading = false,
    this.onRefresh,
  });

  final IconData icon;
  final List<Location> places;
  final String emptyTitle;
  final String emptyBody;
  final Widget Function(Location place) trailingFor;
  final bool loading;

  /// Enables pull-to-refresh when set.
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final scroll = CustomScrollView(
      physics: onRefresh == null ? null : const AlwaysScrollableScrollPhysics(),
      slivers: [
        if (loading)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.terakota),
            ),
          )
        else if (places.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(icon: icon, title: emptyTitle, body: emptyBody),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              16,
              4,
              16,
              24 + MediaQuery.paddingOf(context).bottom,
            ),
            sliver: SliverList.separated(
              itemCount: places.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final place = places[i];
                return TweenAnimationBuilder<double>(
                  key: ValueKey(place.id),
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 300 + 40 * i.clamp(0, 8)),
                  curve: Curves.easeOutCubic,
                  builder: (context, t, child) => Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(24 * (1 - t), 0),
                      child: child,
                    ),
                  ),
                  child: PlaceListCard(
                    location: place,
                    onTap: () => openLocationDetail(context, place),
                    trailing: trailingFor(place),
                  ),
                );
              },
            ),
          ),
      ],
    );
    return onRefresh == null
        ? scroll
        : RefreshIndicator(
            color: AppColors.terakota,
            onRefresh: onRefresh!,
            child: scroll,
          );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox.square(
            dimension: 132,
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: AppColors.gadingDeep),
                  const KawungPattern(color: Color(0x22A9432A), tileSize: 36),
                  Icon(icon, size: 52, color: AppColors.terakota),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {
              final route = ModalRoute.of(context);
              if (route?.canPop ?? false) Navigator.of(context).pop();
              context.read<ShellController>().goTo(ShellTab.home);
            },
            icon: const Icon(Icons.explore_outlined, size: 18),
            label: Text(context.l10n.savedExploreHome),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.terakota,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
