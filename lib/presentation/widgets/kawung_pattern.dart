import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Batik kawung motif: four ovals around each grid point, repeated as a
/// subtle background texture.
class KawungPattern extends StatelessWidget {
  const KawungPattern({
    super.key,
    required this.color,
    this.tileSize = 56,
    this.strokeWidth = 1.2,
  });

  final Color color;
  final double tileSize;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _KawungPainter(color, tileSize, strokeWidth),
      ),
    );
  }
}

class _KawungPainter extends CustomPainter {
  _KawungPainter(this.color, this.tile, this.strokeWidth);

  final Color color;
  final double tile;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;
    final dot = Paint()..color = color;

    final ovalLength = tile * 0.42;
    final ovalWidth = tile * 0.22;
    final offset = tile * 0.24;

    for (var y = 0.0; y <= size.height + tile; y += tile) {
      for (var x = 0.0; x <= size.width + tile; x += tile) {
        for (var k = 0; k < 4; k++) {
          final angle = math.pi / 4 + k * math.pi / 2;
          canvas.save();
          canvas.translate(
            x + math.cos(angle) * offset,
            y + math.sin(angle) * offset,
          );
          canvas.rotate(angle);
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset.zero,
              width: ovalLength,
              height: ovalWidth,
            ),
            stroke,
          );
          canvas.restore();
        }
        canvas.drawCircle(
          Offset(x + tile / 2, y + tile / 2),
          strokeWidth * 1.4,
          dot,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_KawungPainter old) =>
      old.color != color || old.tile != tile || old.strokeWidth != strokeWidth;
}
