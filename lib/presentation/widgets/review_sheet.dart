import 'package:flutter/material.dart';

import '../../domain/entities/location.dart';
import '../../l10n/l10n.dart';
import '../theme/app_colors.dart';

/// Bottom sheet for writing a review.
///
/// [onSubmit] returns true when the review was saved, which closes the sheet.
class ReviewSheet extends StatefulWidget {
  const ReviewSheet({
    super.key,
    required this.location,
    required this.onSubmit,
  });

  final Location location;
  final Future<bool> Function(int rating, String comment) onSubmit;

  static Future<void> show(
    BuildContext context, {
    required Location location,
    required Future<bool> Function(int rating, String comment) onSubmit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReviewSheet(location: location, onSubmit: onSubmit),
    );
  }

  @override
  State<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<ReviewSheet> {
  final _commentController = TextEditingController();
  int _rating = 0;
  bool _submitting = false;

  static List<String> _ratingLabels(AppLocalizations l10n) => [
    l10n.reviewPickRating,
    l10n.reviewVeryBad,
    l10n.reviewBad,
    l10n.reviewOkay,
    l10n.reviewGood,
    l10n.reviewVeryGood,
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final ok = await widget.onSubmit(_rating, _commentController.text.trim());
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + safeBottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.reviewWrite,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F4F6),
                    ),
                    icon: const Icon(
                      Icons.close,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              Text(
                widget.location.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),
              Text(context.l10n.reviewRating, style: _label),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (var star = 1; star <= 5; star++)
                    GestureDetector(
                      onTap: () => setState(() => _rating = star),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.star_rounded,
                          size: 40,
                          color: star <= _rating
                              ? AppColors.prada
                              : const Color(0xFFD1D5DB),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _ratingLabels(context.l10n)[_rating],
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),
              Text(context.l10n.reviewComment, style: _label),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                minLines: 4,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: context.l10n.reviewHint,
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        context.l10n.commonCancel,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _rating == 0 || _submitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.terakota,
                        disabledBackgroundColor: const Color(0xFFD1D5DB),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              context.l10n.commonSave,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _label = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w600,
  color: Color(0xFF374151),
);
