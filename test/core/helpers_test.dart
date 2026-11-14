import 'package:bali_guide_map/core/utils/helpers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calculateDistance', () {
    test('returns 0 for the same point', () {
      expect(calculateDistance(-8.67, 115.21, -8.67, 115.21), 0);
    });

    test('Denpasar to Ubud is roughly 20km', () {
      final d = calculateDistance(-8.6705, 115.2126, -8.5069, 115.2625);
      expect(d, inInclusiveRange(18, 21));
    });

    test('rounds to one decimal', () {
      final d = calculateDistance(-8.6705, 115.2126, -8.5069, 115.2625);
      expect((d * 10) % 1, 0);
    });
  });

  group('formatDistance', () {
    test('uses metres below 1km', () => expect(formatDistance(0.5), '500m'));
    test('uses km from 1km', () => expect(formatDistance(2.345), '2.3km'));
  });
}
