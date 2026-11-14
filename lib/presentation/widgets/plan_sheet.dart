import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/error/errors.dart';
import '../../core/utils/currency_format.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/trip_plan.dart';
import '../../domain/usecases/planner_usecases.dart';
import '../../l10n/l10n.dart';
import '../screens/plan_result_screen.dart';
import '../theme/app_colors.dart';

/// Opens the "Rencana Kunjungan" form for [location]. When the AI returns a
/// plan, the sheet closes and the result page opens.
Future<void> showPlanSheet(BuildContext context, Location location) async {
  final plan = await showModalBottomSheet<TripPlan>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PlanSheet(location: location),
  );
  if (plan == null || !context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => PlanResultScreen(location: location, plan: plan),
    ),
  );
}

const _budgetPresets = [250000, 500000, 1000000, 2000000, 5000000];

class _PlanSheet extends StatefulWidget {
  const _PlanSheet({required this.location});

  final Location location;

  @override
  State<_PlanSheet> createState() => _PlanSheetState();
}

class _PlanSheetState extends State<_PlanSheet> {
  final _budget = TextEditingController(text: '500.000');
  final _notes = TextEditingController();
  int _people = 2;
  int _days = 1;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _budget.dispose();
    _notes.dispose();
    super.dispose();
  }

  int get _budgetValue =>
      int.tryParse(_budget.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  void _setBudget(int value) {
    final text = formatRupiah(value).substring(2);
    _budget.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    setState(() {});
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final plan = await context.read<CreateTripPlanUseCase>().execute(
        TripPlanRequest(
          location: widget.location,
          budget: _budgetValue,
          people: _people,
          days: _days,
          notes: _notes.text,
        ),
      );
      if (mounted) Navigator.of(context).pop(plan);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = _errorText(e);
        });
      }
    }
  }

  String _errorText(Object error) {
    final l10n = context.l10n;
    if (error is PlanInputError) {
      return switch (error.problem) {
        PlanInputProblem.budget => l10n.planErrBudget(
          formatRupiah(CreateTripPlanUseCase.minBudget),
        ),
        PlanInputProblem.people => l10n.planErrPeople(
          CreateTripPlanUseCase.maxPeople,
        ),
        PlanInputProblem.days => l10n.planErrDays(
          CreateTripPlanUseCase.maxDays,
        ),
        PlanInputProblem.notes => l10n.planErrNotes(
          CreateTripPlanUseCase.maxNotes,
        ),
      };
    }
    return l10n.errorMessage(handleError(error));
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.gading,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: _loading ? _buildLoading() : _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _handle() => Center(
    child: Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 10, bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );

  Widget _buildLoading() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _handle(),
          const SizedBox(height: 24),
          const SizedBox.square(
            dimension: 44,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.terakota,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.planBuilding,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.planBuildingBody(
              context.l10n.planPeopleCount(_people),
              context.l10n.planDaysCount(_days),
              formatRupiah(_budgetValue),
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _handle(),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.terakota.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  color: AppColors.terakota,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.planTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      widget.location.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _Label(context.l10n.planBudgetLabel),
          TextField(
            controller: _budget,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _ThousandsFormatter(),
            ],
            onChanged: (_) => setState(() {}),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            decoration: _inputDecoration().copyWith(
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 16, right: 6),
                child: Text(
                  'Rp',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in _budgetPresets)
                ChoiceChip(
                  label: Text(
                    formatRupiahShort(
                      preset,
                      languageCode: context.l10n.localeName,
                    ),
                  ),
                  selected: _budgetValue == preset,
                  onSelected: (_) => _setBudget(preset),
                  showCheckmark: false,
                  selectedColor: AppColors.terakota,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.border),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _budgetValue == preset
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _Stepper(
                  label: context.l10n.planPeople,
                  value: _people,
                  format: context.l10n.planPeopleCount,
                  min: 1,
                  max: CreateTripPlanUseCase.maxPeople,
                  onChanged: (v) => setState(() => _people = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Stepper(
                  label: context.l10n.planDuration,
                  value: _days,
                  format: context.l10n.planDaysCount,
                  min: 1,
                  max: CreateTripPlanUseCase.maxDays,
                  onChanged: (v) => setState(() => _days = v),
                ),
              ),
            ],
          ),
          if (_budgetValue > 0) ...[
            const SizedBox(height: 10),
            Text(
              context.l10n.planPerPersonApprox(
                formatRupiah((_budgetValue / _people).round()),
              ),
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
          const SizedBox(height: 18),
          _Label(context.l10n.planNotesLabel),
          TextField(
            controller: _notes,
            maxLength: CreateTripPlanUseCase.maxNotes,
            maxLines: 2,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration().copyWith(
              hintText: context.l10n.planNotesHint,
              hintStyle: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          if (_error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 18,
                    color: Color(0xFFB42318),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFB42318),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          FilledButton.icon(
            onPressed: _budgetValue >= CreateTripPlanUseCase.minBudget
                ? _submit
                : null,
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: Text(context.l10n.planCreate),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.terakota,
              padding: const EdgeInsets.symmetric(vertical: 15),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.planSheetDisclaimer,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    );
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.terakota, width: 1.5),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    ),
  );
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.format,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;

  /// Value with its unit, such as "2 orang".
  final String Function(int value) format;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: value > min ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove_rounded),
                color: AppColors.terakota,
                tooltip: context.l10n.planDecrease,
              ),
              Expanded(
                child: Text(
                  format(value),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: value < max ? () => onChanged(value + 1) : null,
                icon: const Icon(Icons.add_rounded),
                color: AppColors.terakota,
                tooltip: context.l10n.planIncrease,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Inserts thousands dots while typing: 1500000 -> 1.500.000.
class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('.', '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    final value = int.tryParse(digits);
    if (value == null) return oldValue;
    final text = formatRupiah(value).substring(2);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
