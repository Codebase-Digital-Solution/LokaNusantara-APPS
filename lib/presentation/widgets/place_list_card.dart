import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';

import '../../core/utils/category_style.dart';
import '../../domain/entities/location.dart';
import '../theme/app_colors.dart';
import 'category_icon.dart';
import 'place_image.dart';

/// Horizontal card used by the saved and history lists.
class PlaceListCard extends StatelessWidget {
  const PlaceListCard({
    super.key,
    required this.location,
    required this.onTap,
    this.trailing,
  });

  final Location location;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final style = categoryStyleOf(location.category?.name);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 78,
                height: 78,
                child: PlaceImage(
                  location: location,
                  compact: true,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CategoryIcon(style, size: 14, color: style.color),
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
                      location.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (location.address.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        location.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}
