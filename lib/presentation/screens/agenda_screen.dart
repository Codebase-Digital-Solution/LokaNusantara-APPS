import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:provider/provider.dart';

import '../../core/utils/category_style.dart';
import '../../core/utils/date_format.dart';
import '../../domain/entities/cultural_event.dart';
import '../navigation/location_navigation.dart';
import '../navigation/map_navigation.dart';
import '../providers/agenda_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/category_icon.dart';
import '../widgets/kawung_pattern.dart';

/// Upcoming ceremonies and festivals, highlighted next event first, then
/// grouped by month.
class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  String? _category;

  @override
  Widget build(BuildContext context) {
    final agenda = context.watch<AgendaProvider>();
    final categories = <String>{for (final e in agenda.events) e.category};
    final events = _category == null
        ? agenda.events
        : agenda.events.where((e) => e.category == _category).toList();

    return Scaffold(
      backgroundColor: AppColors.gading,
      body: RefreshIndicator(
        color: AppColors.terakota,
        onRefresh: agenda.load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverSafeArea(
              bottom: false,
              sliver: SliverToBoxAdapter(child: _Header()),
            ),
            if (categories.length > 1)
              SliverToBoxAdapter(
                child: _FilterChips(
                  categories: [
                    for (final key in _categoryOrder)
                      if (categories.contains(key)) key,
                    for (final key in categories)
                      if (!_categoryOrder.contains(key)) key,
                  ],
                  selected: _category,
                  onSelected: (c) => setState(() => _category = c),
                ),
              ),
            ..._body(agenda, events),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(AgendaProvider agenda, List<CulturalEvent> events) {
    if (agenda.loading && !agenda.loaded) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (agenda.error != null && events.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _Message(
            icon: Icons.cloud_off_outlined,
            text: context.l10n.errorMessage(agenda.error!),
            action: context.l10n.commonRetry,
            onAction: agenda.load,
          ),
        ),
      ];
    }
    if (events.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _Message(
            icon: Icons.event_busy_outlined,
            text: context.l10n.agendaEmptyCategory,
          ),
        ),
      ];
    }

    final next = events.first;
    final rest = events.skip(1).toList();
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: _HighlightCard(
            event: next,
            onTap: () => _showEvent(context, next),
          ),
        ),
      ),
      for (final group in _groupByMonth(rest)) ...[
        SliverToBoxAdapter(child: _MonthHeader(date: group.first.startDate)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.separated(
            itemCount: group.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _EventRow(
              event: group[i],
              onTap: () => _showEvent(context, group[i]),
            ),
          ),
        ),
      ],
      SliverToBoxAdapter(
        child: SizedBox(height: 28 + MediaQuery.paddingOf(context).bottom),
      ),
    ];
  }

  static List<List<CulturalEvent>> _groupByMonth(List<CulturalEvent> events) {
    final groups = <List<CulturalEvent>>[];
    for (final e in events) {
      final last = groups.isEmpty ? null : groups.last.first.startDate;
      if (last != null &&
          last.year == e.startDate.year &&
          last.month == e.startDate.month) {
        groups.last.add(e);
      } else {
        groups.add([e]);
      }
    }
    return groups;
  }

  void _showEvent(BuildContext context, CulturalEvent event) =>
      showAgendaEvent(context, event);
}

/// Opens the detail sheet of one agenda item. [context] must stay mounted
/// after the sheet closes (it opens the map from there).
Future<void> showAgendaEvent(BuildContext context, CulturalEvent event) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EventSheet(event: event, hostContext: context),
  );
}

const _categoryOrder = [
  'tradisi',
  'pura',
  'masjid',
  'gereja',
  'vihara',
  'klenteng',
  'kuliner',
];

String _labelOf(BuildContext context, String category) {
  final style = categoryStyleOf(category);
  return style == defaultCategoryStyle ? category : style.labelOf(context.l10n);
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.agendaTitle,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            context.l10n.agendaSubtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, Color color, bool active, VoidCallback onTap) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? color : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: active ? color : AppColors.border),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          chip(
            context.l10n.agendaAll,
            AppColors.sogan,
            selected == null,
            () => onSelected(null),
          ),
          for (final c in categories)
            chip(
              _labelOf(context, c),
              categoryStyleOf(c).color,
              selected == c,
              () => onSelected(c),
            ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.event, required this.onTap});

  final CulturalEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = categoryStyleOf(event.category);
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [style.color, AppColors.sogan],
            ),
          ),
          child: Stack(
            children: [
              const Positioned.fill(
                child: KawungPattern(color: Color(0x1AFFFFFF), tileSize: 56),
              ),
              Positioned(
                right: -16,
                bottom: -16,
                child: CategoryIcon(
                  style,
                  size: 140,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _Pill(
                          text: context.l10n.agendaSoon,
                          background: AppColors.pradaLight,
                          foreground: AppColors.sogan,
                        ),
                        const SizedBox(width: 8),
                        _Pill(
                          text: countdownLabel(
                            event.startDate,
                            event.lastDay,
                            context.l10n,
                          ),
                          background: Colors.white.withValues(alpha: 0.2),
                          foreground: Colors.white,
                        ),
                        if (event.isEstimate) ...[
                          const SizedBox(width: 8),
                          _Pill(
                            text: context.l10n.agendaEstimate,
                            background: Colors.white.withValues(alpha: 0.2),
                            foreground: Colors.white,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      event.name,
                      style: const TextStyle(
                        fontSize: 24,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dateRange(event.startDate, event.endDate, context.l10n),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.location?.name ?? event.region,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Text(
            monthYear(date, context.l10n),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Divider(color: AppColors.border)),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.onTap});

  final CulturalEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = categoryStyleOf(event.category);
    final place = event.location?.name ?? event.region;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 64,
                color: style.color.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${event.startDate.day}',
                      style: TextStyle(
                        fontSize: 24,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        color: style.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shortWeekday(event.startDate, context.l10n),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: style.color,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        event.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.isMultiDay
                            ? dateRange(
                                event.startDate,
                                event.endDate,
                                context.l10n,
                              )
                            : place,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _Pill(
                            text: _labelOf(context, event.category),
                            background: style.color.withValues(alpha: 0.12),
                            foreground: style.color,
                          ),
                          if (event.isEstimate)
                            _Pill(
                              text: context.l10n.agendaEstimate,
                              background: AppColors.gadingDeep,
                              foreground: AppColors.textSecondary,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.chevron_right, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    required this.background,
    required this.foreground,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}

class _EventSheet extends StatelessWidget {
  const _EventSheet({required this.event, required this.hostContext});

  final CulturalEvent event;

  /// Context of the agenda screen, still mounted after the sheet closes.
  final BuildContext hostContext;

  @override
  Widget build(BuildContext context) {
    final style = categoryStyleOf(event.category);
    final location = event.location;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: style.color,
                    shape: BoxShape.circle,
                  ),
                  child: CategoryIcon(style, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    event.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoLine(
              icon: Icons.event_outlined,
              text: dateRange(event.startDate, event.endDate, context.l10n),
            ),
            _InfoLine(
              icon: Icons.schedule,
              text: countdownLabel(
                event.startDate,
                event.lastDay,
                context.l10n,
              ),
            ),
            _InfoLine(
              icon: Icons.place_outlined,
              text: location == null
                  ? event.region
                  : '${location.name}, ${event.region}',
            ),
            if (event.isEstimate)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gading,
                  borderRadius: BorderRadius.circular(12),
                  border: const Border(
                    left: BorderSide(color: AppColors.prada, width: 3),
                  ),
                ),
                child: Text(
                  context.l10n.agendaEstimateNote,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            if (event.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                event.description,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (location != null) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        showLocationOnMap(hostContext, location);
                      },
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: Text(context.l10n.agendaViewOnMap),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.terakota,
                        side: const BorderSide(color: AppColors.terakota),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        openLocationDetail(hostContext, location);
                      },
                      icon: const Icon(Icons.auto_stories_outlined, size: 18),
                      label: Text(context.l10n.agendaLocationDetail),
                      style: FilledButton.styleFrom(
                        backgroundColor: style.color,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.terakota),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.text,
    this.action,
    this.onAction,
  });

  final IconData icon;
  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 52, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (action != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onAction, child: Text(action!)),
          ],
        ],
      ),
    );
  }
}
