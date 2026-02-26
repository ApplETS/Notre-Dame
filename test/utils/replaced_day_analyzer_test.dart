// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/replaced_day.dart';
import 'package:notredame/utils/replaced_day_analyzer.dart';

void main() {
  ReplacedDay createReplacedDay({
    required DateTime originalDate,
    required DateTime replacementDate,
    String description = 'Action de graces',
  }) {
    return ReplacedDay(
      originalDate: originalDate,
      replacementDate: replacementDate,
      description: description,
    );
  }

  group('ReplacedDayAnalyzer -', () {
    final reference = DateTime(2024, 3, 4); // A Monday

    group('getUpcoming -', () {
      test('returns null when list is empty', () {
        final analyzer = ReplacedDayAnalyzer(replacedDays: [], now: reference);

        expect(analyzer.getUpcoming(), isNull);
      });

      test('returns null when all replaced days are in the past', () {
        final replacedDays = [
          createReplacedDay(
            originalDate: reference.subtract(const Duration(days: 1)),
            replacementDate: reference.subtract(const Duration(days: 8)),
          ),
          createReplacedDay(
            originalDate: reference.subtract(const Duration(days: 3)),
            replacementDate: reference.subtract(const Duration(days: 10)),
          ),
        ];
        final analyzer = ReplacedDayAnalyzer(replacedDays: replacedDays, now: reference);

        expect(analyzer.getUpcoming(), isNull);
      });

      test('returns null when all replaced days are 7+ days away', () {
        final replacedDays = [
          createReplacedDay(
            originalDate: reference.add(const Duration(days: 7)),
            replacementDate: reference.subtract(const Duration(days: 1)),
          ),
          createReplacedDay(
            originalDate: reference.add(const Duration(days: 10)),
            replacementDate: reference.subtract(const Duration(days: 1)),
          ),
        ];
        final analyzer = ReplacedDayAnalyzer(replacedDays: replacedDays, now: reference);

        expect(analyzer.getUpcoming(), isNull);
      });

      test('returns the replaced day when originalDate is today', () {
        final replacedDay = createReplacedDay(
          originalDate: reference,
          replacementDate: reference.subtract(const Duration(days: 7)),
        );
        final analyzer = ReplacedDayAnalyzer(replacedDays: [replacedDay], now: reference);

        expect(analyzer.getUpcoming(), replacedDay);
      });

      test('returns the replaced day when originalDate is within 7 days', () {
        final replacedDay = createReplacedDay(
          originalDate: reference.add(const Duration(days: 3)),
          replacementDate: reference.subtract(const Duration(days: 4)),
        );
        final analyzer = ReplacedDayAnalyzer(replacedDays: [replacedDay], now: reference);

        expect(analyzer.getUpcoming(), replacedDay);
      });

      test('does not return a replaced day exactly 7 days from now', () {
        final replacedDay = createReplacedDay(
          originalDate: reference.add(const Duration(days: 7)),
          replacementDate: reference.subtract(const Duration(days: 1)),
        );
        final analyzer = ReplacedDayAnalyzer(replacedDays: [replacedDay], now: reference);

        expect(analyzer.getUpcoming(), isNull);
      });

      test('returns the nearest one when multiple are within range', () {
        final nearest = createReplacedDay(
          originalDate: reference.add(const Duration(days: 1)),
          replacementDate: reference.subtract(const Duration(days: 6)),
        );
        final farther = createReplacedDay(
          originalDate: reference.add(const Duration(days: 5)),
          replacementDate: reference.subtract(const Duration(days: 2)),
        );
        final analyzer = ReplacedDayAnalyzer(replacedDays: [nearest, farther], now: reference);

        expect(analyzer.getUpcoming(), nearest);
      });

      test('returns the nearest even if list is unsorted', () {
        final nearest = createReplacedDay(
          originalDate: reference.add(const Duration(days: 2)),
          replacementDate: reference.subtract(const Duration(days: 5)),
        );
        final farther = createReplacedDay(
          originalDate: reference.add(const Duration(days: 6)),
          replacementDate: reference.subtract(const Duration(days: 1)),
        );
        final analyzer = ReplacedDayAnalyzer(replacedDays: [farther, nearest], now: reference);

        expect(analyzer.getUpcoming(), nearest);
      });
    });

    group('isCancellation -', () {
      test('returns true when replacementDate is before originalDate', () {
        final replacedDay = createReplacedDay(
          originalDate: reference.add(const Duration(days: 3)),
          replacementDate: reference.subtract(const Duration(days: 4)),
        );
        final analyzer = ReplacedDayAnalyzer(replacedDays: [replacedDay], now: reference);

        expect(analyzer.isCancellation(replacedDay), isTrue);
      });

      test('returns false when replacementDate is after originalDate', () {
        final replacedDay = createReplacedDay(
          originalDate: reference.add(const Duration(days: 3)),
          replacementDate: reference.add(const Duration(days: 10)),
        );
        final analyzer = ReplacedDayAnalyzer(replacedDays: [replacedDay], now: reference);

        expect(analyzer.isCancellation(replacedDay), isFalse);
      });
    });
  });
}
