import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/error/errors.dart';
import '../../core/utils/currency_format.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/trip_plan.dart';
import '../../l10n/l10n.dart';
import '../navigation/location_navigation.dart';
import '../providers/auth_provider.dart';
import '../providers/saved_plans_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/dialogs.dart';
import '../widgets/kawung_pattern.dart';

const _good = Color(0xFF1F7A5C);
const _warn = Color(0xFFB4630C);

/// The AI-generated visit plan: budget check, cost breakdown, itinerary and
/// tips. A fresh plan can be saved to the account; a saved one ([savedId])
/// can be deleted.
class PlanResultScreen extends StatelessWidget {
  const PlanResultScreen({
    super.key,
    required this.location,
    required this.plan,
    this.savedId,
  });

  final Location location;
  final TripPlan plan;

  /// Set when this plan was opened from the saved list.
  final int? savedId;

  Future<void> _delete(BuildContext context) async {
    final ok = await showConfirmDialog(
      context,
      title: context.l10n.planDeleteTitle,
      message: context.l10n.planDeleteMessage,
      confirmLabel: context.l10n.planDelete,
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    final plans = context.read<SavedPlansProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await plans.delete(savedId!);
      navigator.pop();
    } on AppError catch (e) {
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(l10n.planDeleteFailed(l10n.errorMessage(e))),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = <int, List<PlanStep>>{};
    for (final step in plan.itinerary) {
      days.putIfAbsent(step.day < 1 ? 1 : step.day, () => []).add(step);
    }

    return Scaffold(
      backgroundColor: AppColors.gading,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 168,
            backgroundColor: AppColors.terakota,
            foregroundColor: Colors.white,
            title: Text(
              context.l10n.planTitle,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            actions: [
              if (savedId != null)
                IconButton(
                  tooltip: context.l10n.planDeleteTitle,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _delete(context),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.terakota, AppColors.sogan],
                  ),
                ),
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: KawungPattern(
                        color: Color(0x1AF6D98A),
                        tileSize: 64,
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            context.l10n.planMeta(
                              context.l10n.planPeopleCount(plan.people),
                              context.l10n.planDaysCount(plan.days),
                              formatRupiah(plan.budget),
                            ),
                            style: TextStyle(
                              fontSize: 13,
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
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              32 + MediaQuery.paddingOf(context).bottom,
            ),
            sliver: SliverList.list(
              children: [
                _BudgetCard(plan: plan),
                if (plan.summary.isNotEmpty)
                  _Section(
                    icon: Icons.auto_awesome,
                    title: context.l10n.planSummary,
                    child: _Body(plan.summary),
                  ),
                if (plan.costs.isNotEmpty)
                  _Section(
                    icon: Icons.receipt_long_rounded,
                    title: context.l10n.planCosts,
                    child: Column(
                      children: [
                        for (final c in plan.costs) _CostRow(cost: c),
                        const Divider(height: 20, color: AppColors.border),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                context.l10n.planTotalEstimate,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              formatRupiah(plan.totalEstimate),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                if (days.isNotEmpty)
                  _Section(
                    icon: Icons.schedule_rounded,
                    title: context.l10n.planSchedule,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final entry in days.entries) ...[
                          if (days.length > 1)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8, top: 4),
                              child: Text(
                                context.l10n.planDay(entry.key),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.terakota,
                                ),
                              ),
                            ),
                          for (var i = 0; i < entry.value.length; i++)
                            _StepRow(
                              step: entry.value[i],
                              last: i == entry.value.length - 1,
                            ),
                        ],
                      ],
                    ),
                  ),
                if (plan.tips.isNotEmpty)
                  _Section(
                    icon: Icons.lightbulb_outline_rounded,
                    title: context.l10n.planTips,
                    child: Column(
                      children: [
                        for (final tip in plan.tips)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 6, right: 10),
                                  child: Icon(
                                    Icons.circle,
                                    size: 6,
                                    color: AppColors.prada,
                                  ),
                                ),
                                Expanded(child: _Body(tip)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    context.l10n.planDisclaimer,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: savedId == null
          ? _SaveBar(location: location, plan: plan)
          : null,
    );
  }
}

/// "Simpan Rencana" at the bottom of a fresh plan. Asks the user to sign in
/// first when needed.
class _SaveBar extends StatefulWidget {
  const _SaveBar({required this.location, required this.plan});

  final Location location;
  final TripPlan plan;

  @override
  State<_SaveBar> createState() => _SaveBarState();
}

class _SaveBarState extends State<_SaveBar> {
  bool _saving = false;
  bool _saved = false;

  Future<void> _save() async {
    final auth = context.read<AuthProvider>();
    final plans = context.read<SavedPlansProvider>();
    if (!auth.isAuthenticated) {
      final signedIn = await showAuthFlow(context);
      if (!signedIn || !mounted) return;
      // Run as the new user now instead of waiting for the next build.
      plans.setUser(auth.user?.id);
    }
    setState(() => _saving = true);
    final l10n = context.l10n;
    String message;
    try {
      await plans.save(widget.location, widget.plan);
      _saved = true;
      message = l10n.planSavedMessage;
    } on AppError catch (e) {
      message = l10n.planSaveFailed(l10n.errorMessage(e));
    }
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
      );
  }

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
      child: FilledButton(
        onPressed: _saving || _saved ? null : _save,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.terakota,
          disabledBackgroundColor: _saved
              ? _good
              : AppColors.terakota.withValues(alpha: 0.5),
          disabledForegroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _saving
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                _saved
                    ? context.l10n.planSavedLabel
                    : context.l10n.planSaveButton,
              ),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.plan});
  final TripPlan plan;

  @override
  Widget build(BuildContext context) {
    final ok = plan.withinBudget;
    final status = ok ? _good : _warn;
    final used = plan.budget <= 0
        ? 1.0
        : (plan.totalEstimate / plan.budget).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: status.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      ok
                          ? Icons.check_circle_rounded
                          : Icons.warning_amber_rounded,
                      size: 16,
                      color: status,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      ok
                          ? context.l10n.planWithinBudget
                          : context.l10n.planOverBudget,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: status,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            context.l10n.planEstimatedTotal,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            formatRupiah(plan.totalEstimate),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: used,
              minHeight: 8,
              color: status,
              backgroundColor: AppColors.gadingDeep,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Figure(
                  label: context.l10n.planPerPerson,
                  value: formatRupiah(plan.perPersonEstimate),
                ),
              ),
              Expanded(
                child: _Figure(
                  label: ok
                      ? context.l10n.planBudgetLeft
                      : context.l10n.planShortfall,
                  value: formatRupiah(plan.remaining.abs()),
                ),
              ),
            ],
          ),
          if (plan.budgetNote.isNotEmpty) ...[
            const SizedBox(height: 14),
            _Body(plan.budgetNote),
          ],
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    ],
  );
}

IconData _costIcon(String category) => switch (category) {
  'transportasi' => Icons.directions_car_rounded,
  'tiket' => Icons.confirmation_number_rounded,
  'donasi' => Icons.volunteer_activism_rounded,
  'makan' => Icons.restaurant_rounded,
  'sewa' => Icons.checkroom_rounded,
  'pemandu' => Icons.record_voice_over_rounded,
  'oleh-oleh' => Icons.shopping_bag_rounded,
  _ => Icons.more_horiz_rounded,
};

class _CostRow extends StatelessWidget {
  const _CostRow({required this.cost});
  final PlanCost cost;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.terakota.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _costIcon(cost.category),
              size: 18,
              color: AppColors.terakota,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cost.item,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (cost.note.isNotEmpty)
                  Text(
                    cost.note,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatRupiah(cost.amount),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.last});
  final PlanStep step;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final place = step.location;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              step.time,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: place != null ? AppColors.terakota : Colors.white,
                  border: Border.all(color: AppColors.terakota, width: 2),
                ),
              ),
              if (!last)
                Expanded(child: Container(width: 2, color: AppColors.border)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Body(step.activity),
                  if (place != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => openLocationDetail(context, place),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.terakota.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.place_rounded,
                                size: 14,
                                color: AppColors.terakota,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  place.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.terakota,
                                  ),
                                ),
                              ),
                            ],
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
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.terakota),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
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

class _Body extends StatelessWidget {
  const _Body(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 14,
      height: 1.5,
      color: AppColors.textSecondary,
    ),
  );
}
