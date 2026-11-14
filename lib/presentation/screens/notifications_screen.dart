import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:provider/provider.dart';

import '../../core/utils/category_style.dart';
import '../../core/utils/date_format.dart';
import '../../domain/entities/cultural_event.dart';
import '../providers/agenda_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/category_icon.dart';
import 'agenda_screen.dart';

/// How far ahead agenda items count as notifications.
const notificationWindowDays = 14;

/// Agenda items happening today or within [days] days, soonest first.
List<CulturalEvent> upcomingEvents(
  List<CulturalEvent> events, {
  int days = notificationWindowDays,
  DateTime? now,
}) {
  final t = now ?? DateTime.now();
  final today = DateTime(t.year, t.month, t.day);
  final until = today.add(Duration(days: days));
  return events
      .where((e) => !e.lastDay.isBefore(today) && !e.startDate.isAfter(until))
      .toList()
    ..sort((a, b) => a.startDate.compareTo(b.startDate));
}

/// Reminders for cultural events coming up soon.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final agenda = context.watch<AgendaProvider>();
    final items = upcomingEvents(agenda.events);

    return Scaffold(
      backgroundColor: AppColors.gading,
      appBar: AppBar(
        backgroundColor: AppColors.gading,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        title: Text(
          context.l10n.notifTitle,
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.terakota,
        onRefresh: agenda.load,
        child: agenda.loading && items.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.terakota),
              )
            : items.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [_Empty()],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  16,
                  4,
                  16,
                  24 + MediaQuery.paddingOf(context).bottom,
                ),
                itemCount: items.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 2),
                      child: Text(
                        context.l10n.notifWindow(notificationWindowDays),
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }
                  return _EventTile(event: items[i - 1]);
                },
              ),
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});
  final CulturalEvent event;

  @override
  Widget build(BuildContext context) {
    final style = categoryStyleOf(event.category);
    final when = countdownLabel(event.startDate, event.lastDay, context.l10n);
    final soon =
        when == context.l10n.dateToday ||
        when == context.l10n.dateTomorrow ||
        when == context.l10n.dateOngoing;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showAgendaEvent(context, event),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: style.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: CategoryIcon(style, size: 22, color: style.color),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        dateRange(event.startDate, event.endDate, context.l10n),
                        if (event.region.isNotEmpty) event.region,
                      ].join('  •  '),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (event.isEstimate)
                      Padding(
                        padding: EdgeInsets.only(top: 3),
                        child: Text(
                          context.l10n.notifEstimatedDate,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: soon
                      ? AppColors.terakota
                      : AppColors.terakota.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  when,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: soon ? Colors.white : AppColors.terakota,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(32, 120, 32, 32),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 56,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 14),
          Text(
            context.l10n.notifEmptyTitle,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            context.l10n.notifEmptyBody(notificationWindowDays),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
