// Renders the SVG brand assets to the PNGs used for launcher icons and the
// native splash. Run after editing assets/brand/*.svg:
//
//   flutter test tool/render_brand_assets_test.dart
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _render(String svgPath, String outPath,
    {required int size, required double fraction}) async {
  final info = await vg.loadPicture(
      SvgStringLoader(File(svgPath).readAsStringSync()), null);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final scale =
      size * fraction / math.max(info.size.width, info.size.height);
  canvas.translate((size - info.size.width * scale) / 2,
      (size - info.size.height * scale) / 2);
  canvas.scale(scale);
  canvas.drawPicture(info.picture);
  final image = await recorder.endRecording().toImage(size, size);
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  File(outPath).writeAsBytesSync(png!.buffer.asUint8List());
  info.picture.dispose();
}

void main() {
  testWidgets('render brand assets', (tester) async {
    await tester.runAsync(() async {
      // Full-bleed icon for iOS and legacy Android.
      await _render('assets/brand/app_icon.svg', 'assets/brand/app_icon.png',
          size: 1024, fraction: 1);
      // Android adaptive foreground: keep the mark inside the 66% safe zone.
      await _render('assets/brand/logo_mark.svg',
          'assets/brand/app_icon_foreground.png',
          size: 1024, fraction: 0.5);
      // Native splash logo (also fits the Android 12 circular icon area).
      await _render('assets/brand/logo_mark.svg',
          'assets/brand/splash_logo.png',
          size: 1152, fraction: 0.5);
    });
  });
}
