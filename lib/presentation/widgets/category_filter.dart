import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';

import '../../core/utils/category_style.dart';
import '../../domain/entities/category.dart';
import '../theme/app_colors.dart';
import 'category_icon.dart';

class CategoryFilter extends StatelessWidget {
  const CategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  final List<Category> categories;
  final int? selectedCategory;
  final ValueChanged<int?> onSelectCategory;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _CategoryItem(
            icon: const Icon(Icons.explore, size: 26, color: Colors.white),
            color: AppColors.sogan,
            label: context.l10n.homeCategoryAll,
            active: selectedCategory == null,
            onTap: () => onSelectCategory(null),
          ),
          for (final category in categories)
            Builder(
              builder: (context) {
                final style = categoryStyleOf(category.name);
                return _CategoryItem(
                  icon: CategoryIcon(style, size: 28),
                  color: style.color,
                  label: style == defaultCategoryStyle
                      ? category.name
                      : style.labelOf(context.l10n),
                  active: selectedCategory == category.id,
                  onTap: () => onSelectCategory(category.id),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final Widget icon;
  final Color color;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: active ? 1 : 0.75),
                shape: BoxShape.circle,
                border: active
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: active ? 0.4 : 0.2),
                    blurRadius: active ? 6 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(child: icon),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                color: active ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
