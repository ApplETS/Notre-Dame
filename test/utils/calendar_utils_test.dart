import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notredame/utils/calendar_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('getTimeDimensions', () {
    test('returns a positive size', () {
      final size = getTimeDimensions(const TextStyle(fontSize: 14), TextDirection.ltr, TextScaler.noScaling);

      expect(size.width, greaterThan(0));
      expect(size.height, greaterThan(0));
    });

    test('measures "00:00" using the font size', () {
      final size = getTimeDimensions(const TextStyle(fontSize: 10), TextDirection.ltr, TextScaler.noScaling);

      expect(size.width, closeTo("00:00".length * 10, 0.01));
      expect(size.height, closeTo(10, 0.01));
    });

    test('larger font size produces a larger size', () {
      final small = getTimeDimensions(const TextStyle(fontSize: 10), TextDirection.ltr, TextScaler.noScaling);
      final large = getTimeDimensions(const TextStyle(fontSize: 20), TextDirection.ltr, TextScaler.noScaling);

      expect(large.width, greaterThan(small.width));
      expect(large.height, greaterThan(small.height));
      expect(large.width, closeTo(small.width * 2, 0.01));
      expect(large.height, closeTo(small.height * 2, 0.01));
    });

    test('applies the text scaler', () {
      const style = TextStyle(fontSize: 12);

      final unscaled = getTimeDimensions(style, TextDirection.ltr, TextScaler.noScaling);
      final scaled = getTimeDimensions(style, TextDirection.ltr, const TextScaler.linear(2.0));

      expect(scaled.width, closeTo(unscaled.width * 2, 0.01));
      expect(scaled.height, closeTo(unscaled.height * 2, 0.01));
    });

    test('a scale factor of 1.0 matches no scaling', () {
      const style = TextStyle(fontSize: 16);

      final noScaling = getTimeDimensions(style, TextDirection.ltr, TextScaler.noScaling);
      final linearOne = getTimeDimensions(style, TextDirection.ltr, const TextScaler.linear(1.0));

      expect(linearOne, noScaling);
    });

    test('scale factor below 1.0 shrinks the size', () {
      const style = TextStyle(fontSize: 20);

      final unscaled = getTimeDimensions(style, TextDirection.ltr, TextScaler.noScaling);
      final scaled = getTimeDimensions(style, TextDirection.ltr, const TextScaler.linear(0.5));

      expect(scaled.width, closeTo(unscaled.width / 2, 0.01));
      expect(scaled.height, closeTo(unscaled.height / 2, 0.01));
    });

    test('text direction does not change the dimensions', () {
      const style = TextStyle(fontSize: 14);

      final ltr = getTimeDimensions(style, TextDirection.ltr, TextScaler.noScaling);
      final rtl = getTimeDimensions(style, TextDirection.rtl, TextScaler.noScaling);

      expect(rtl, ltr);
    });
  });
}
