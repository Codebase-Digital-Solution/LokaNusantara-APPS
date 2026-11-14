import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/utils/category_style.dart';
import '../../domain/entities/location.dart';
import '../theme/app_colors.dart';
import 'category_icon.dart';
import 'kawung_pattern.dart';

/// Cover image for a location. Until real photos exist (or when loading
/// fails) it shows a "broken image" placeholder tinted by category.
class PlaceImage extends StatelessWidget {
  const PlaceImage({
    super.key,
    required this.location,
    this.height,
    this.borderRadius = BorderRadius.zero,
    this.compact = false,
  });

  final Location location;
  final double? height;
  final BorderRadius borderRadius;

  /// Smaller placeholder content for thumbnails.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final url = location.imageUrl;
    final placeholder = _Placeholder(location: location, compact: compact);
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: url == null
            ? placeholder
            : Image.network(
                url,
                headers: ApiClient.mediaHeaders,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : placeholder,
              ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.location, required this.compact});

  final Location location;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = categoryStyleOf(location.category?.name);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(style.color, Colors.white, 0.15)!,
            Color.lerp(style.color, AppColors.sogan, 0.55)!,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          KawungPattern(
            color: Colors.white.withValues(alpha: 0.10),
            tileSize: compact ? 28 : 44,
          ),
          Positioned(
            right: compact ? -8 : -14,
            bottom: compact ? -8 : -14,
            child: CategoryIcon(
              style,
              size: compact ? 52 : 96,
              color: Colors.white.withValues(alpha: 0.16),
            ),
          ),
          Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: compact ? 22 : 34,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}
