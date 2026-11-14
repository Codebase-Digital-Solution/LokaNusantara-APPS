import 'package:flutter/material.dart';

import '../../core/utils/category_style.dart';
import '../../domain/entities/location.dart';
import 'category_icon.dart';

class LocationMarker extends StatelessWidget {
  const LocationMarker({
    super.key,
    required this.location,
    required this.onTap,
  });

  static const size = 34.0;

  final Location location;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = categoryStyleOf(location.category?.name);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: style.color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: CategoryIcon(style, size: 17),
      ),
    );
  }
}
