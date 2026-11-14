import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/utils/category_style.dart';

/// Draws a category glyph (custom SVG, or the Material fallback) in [color].
class CategoryIcon extends StatelessWidget {
  const CategoryIcon(
    this.style, {
    super.key,
    this.size = 22,
    this.color = Colors.white,
  });

  final CategoryStyle style;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final asset = style.asset;
    if (asset == null) return Icon(style.icon, size: size, color: color);
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
