import 'package:bali_guide_map/presentation/screens/onboarding_screen.dart';
import 'package:bali_guide_map/presentation/widgets/masonry_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('masonry grid puts each item in the shortest column', (
    tester,
  ) async {
    // Heights: 300 -> col0, 100 -> col1, 100 -> col1, 50 -> col1 (still shorter).
    const heights = [300.0, 100.0, 100.0, 50.0];
    await tester.pumpWidget(
      MaterialApp(
        home: SingleChildScrollView(
          child: MasonryGrid<double>(
            items: heights,
            spacing: 0,
            heightOf: (h) => h,
            itemBuilder: (_, h, i) => SizedBox(height: h, child: Text('t$i')),
          ),
        ),
      ),
    );
    final x0 = tester.getTopLeft(find.text('t0')).dx;
    for (final i in [1, 2, 3]) {
      expect(tester.getTopLeft(find.text('t$i')).dx, greaterThan(x0));
    }
  });

  testWidgets('onboarding: skip finishes, last page shows start button', (
    tester,
  ) async {
    var done = 0;
    await tester.pumpWidget(
      MaterialApp(home: OnboardingScreen(onDone: () => done++)),
    );
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Lewati'));
    expect(done, 1);

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      // First frame starts the page animation, the second lets it finish.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Simpan & Temukan Rute'), findsOneWidget);
    await tester.tap(find.text('Mulai Jelajah'));
    expect(done, 2);
  });
}
