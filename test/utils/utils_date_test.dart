// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/utils/utils.dart';

void main() {
  group('Utils date utilities -', () {
    group('dateOnly -', () {
      test('strips time from DateTime and returns UTC', () {
        final dateWithTime = DateTime(2024, 3, 15, 14, 30, 45, 123);
        final result = Utils.dateOnly(dateWithTime);

        expect(result, DateTime.utc(2024, 3, 15));
        expect(result.isUtc, isTrue);
        expect(result.hour, 0);
        expect(result.minute, 0);
        expect(result.second, 0);
        expect(result.millisecond, 0);
      });

      test('returns UTC date with same year/month/day', () {
        final localDate = DateTime(2024, 3, 15);
        final result = Utils.dateOnly(localDate);

        expect(result.year, 2024);
        expect(result.month, 3);
        expect(result.day, 15);
        expect(result.isUtc, isTrue);
      });
    });

    group('startOfWeek -', () {
      test('returns Monday for a Wednesday', () {
        // Wednesday March 13, 2024
        final wednesday = DateTime(2024, 3, 13, 10, 30);
        final result = Utils.startOfWeek(wednesday);

        // Monday March 11, 2024 (UTC)
        expect(result, DateTime.utc(2024, 3, 11));
        expect(result.weekday, DateTime.monday);
        expect(result.isUtc, isTrue);
      });

      test('returns Monday for a Monday', () {
        final monday = DateTime(2024, 3, 11, 9, 0);
        final result = Utils.startOfWeek(monday);

        expect(result, DateTime.utc(2024, 3, 11));
        expect(result.weekday, DateTime.monday);
      });

      test('returns Monday for a Sunday', () {
        // Sunday March 17, 2024
        final sunday = DateTime(2024, 3, 17, 18, 0);
        final result = Utils.startOfWeek(sunday);

        // Monday March 11, 2024
        expect(result, DateTime.utc(2024, 3, 11));
        expect(result.weekday, DateTime.monday);
      });

      test('handles week crossing month boundary', () {
        // Wednesday May 1, 2024
        final wednesday = DateTime(2024, 5, 1);
        final result = Utils.startOfWeek(wednesday);

        // Monday April 29, 2024
        expect(result, DateTime.utc(2024, 4, 29));
        expect(result.weekday, DateTime.monday);
      });

      test('handles week crossing year boundary', () {
        // Wednesday January 3, 2024
        final wednesday = DateTime(2024, 1, 3);
        final result = Utils.startOfWeek(wednesday);

        // Monday January 1, 2024
        expect(result, DateTime.utc(2024, 1, 1));
        expect(result.weekday, DateTime.monday);
      });
    });

    group('daysBetween -', () {
      test('returns positive days for future date', () {
        final start = DateTime(2024, 3, 10);
        final end = DateTime(2024, 3, 15);

        // March 10 to March 15 is 5 days difference
        expect(Utils.daysBetween(start, end), 5);
      });

      test('returns negative days for past date', () {
        final start = DateTime(2024, 3, 15);
        final end = DateTime(2024, 3, 10);

        expect(Utils.daysBetween(start, end), -5);
      });

      test('returns zero for same date', () {
        final date = DateTime(2024, 3, 15);

        expect(Utils.daysBetween(date, date), 0);
      });

      test('ignores time component - same day different times', () {
        final start = DateTime(2024, 3, 10, 8, 0);
        final end = DateTime(2024, 3, 10, 23, 59);

        // Same day, different times should be 0 days
        expect(Utils.daysBetween(start, end), 0);
      });

      test('handles consecutive days', () {
        final start = DateTime(2024, 3, 10);
        final end = DateTime(2024, 3, 11);

        expect(Utils.daysBetween(start, end), 1);
      });

      test('handles month boundaries', () {
        final start = DateTime(2024, 3, 28);
        final end = DateTime(2024, 4, 2);

        expect(Utils.daysBetween(start, end), 5);
      });
    });

    group('monthsRemaining -', () {
      test('returns positive months when end is in future', () {
        final now = DateTime(2024, 3, 15);
        final endDate = DateTime(2024, 6, 15);

        expect(Utils.monthsRemaining(endDate, now), 3);
      });

      test('returns zero when end is same month', () {
        final now = DateTime(2024, 3, 15);
        final endDate = DateTime(2024, 3, 30);

        expect(Utils.monthsRemaining(endDate, now), 0);
      });

      test('returns zero when end is in past', () {
        final now = DateTime(2024, 6, 15);
        final endDate = DateTime(2024, 3, 15);

        expect(Utils.monthsRemaining(endDate, now), 0);
      });

      test('handles year boundary', () {
        final now = DateTime(2024, 11, 15);
        final endDate = DateTime(2025, 2, 15);

        expect(Utils.monthsRemaining(endDate, now), 3);
      });
    });

    group('weeksCompleted -', () {
      test('returns 0 for less than 7 days', () {
        final startDate = DateTime(2024, 3, 10);
        final now = DateTime(2024, 3, 15); // 5 days difference

        expect(Utils.weeksCompleted(startDate, now), 0);
      });

      test('returns 1 for 7 days difference', () {
        final startDate = DateTime(2024, 3, 10);
        final now = DateTime(2024, 3, 17); // 7 days difference

        expect(Utils.weeksCompleted(startDate, now), 1);
      });

      test('returns 2 for 14 days difference', () {
        final startDate = DateTime(2024, 3, 10);
        final now = DateTime(2024, 3, 24); // 14 days difference

        expect(Utils.weeksCompleted(startDate, now), 2);
      });

      test('truncates partial weeks', () {
        final startDate = DateTime(2024, 3, 10);
        final now = DateTime(2024, 3, 20); // 10 days = 1 week + 3 days

        expect(Utils.weeksCompleted(startDate, now), 1);
      });

      test('handles negative when now is before start', () {
        final startDate = DateTime(2024, 3, 20);
        final now = DateTime(2024, 3, 6); // 14 days before

        expect(Utils.weeksCompleted(startDate, now), -2);
      });
    });

    group('weeksRemaining -', () {
      test('returns positive weeks when end is in future', () {
        final now = DateTime(2024, 3, 10);
        final endDate = DateTime(2024, 3, 31); // 21 days difference

        expect(Utils.weeksRemaining(endDate, now), 3);
      });

      test('returns 0 for less than 7 days remaining', () {
        final now = DateTime(2024, 3, 26);
        final endDate = DateTime(2024, 3, 31); // 5 days difference

        expect(Utils.weeksRemaining(endDate, now), 0);
      });

      test('returns 0 when end is in past', () {
        final now = DateTime(2024, 3, 31);
        final endDate = DateTime(2024, 3, 10);

        expect(Utils.weeksRemaining(endDate, now), 0);
      });

      test('truncates partial weeks', () {
        final now = DateTime(2024, 3, 10);
        final endDate = DateTime(2024, 3, 28); // 18 days = 2 weeks + 4 days

        expect(Utils.weeksRemaining(endDate, now), 2);
      });
    });
  });
}
