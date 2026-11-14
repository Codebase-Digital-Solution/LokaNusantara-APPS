import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';

/// A cover photo laid over a coloured backdrop: it fades in once loaded and
/// disappears on error, so the backdrop stays as the fallback. Adds a dark
/// scrim so white text on top stays readable.
class CoverPhoto extends StatelessWidget {
  const CoverPhoto({super.key, required this.url, this.onTap, this.heroTag});

  final String url;
  final VoidCallback? onTap;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    Widget image = Image.network(
      url,
      headers: ApiClient.mediaHeaders,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, sync) => AnimatedOpacity(
        opacity: sync || frame != null ? 1 : 0,
        duration: const Duration(milliseconds: 350),
        child: child,
      ),
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
    if (heroTag != null) image = Hero(tag: heroTag!, child: image);
    if (onTap != null) image = GestureDetector(onTap: onTap, child: image);

    return Stack(
      fit: StackFit.expand,
      children: [
        image,
        const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.35, 0.6, 1],
                colors: [
                  Color(0x66000000),
                  Color(0x00000000),
                  Color(0x1A000000),
                  Color(0xB3000000),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
