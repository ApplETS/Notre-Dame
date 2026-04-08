// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/utils/date_extensions.dart';

void main() {
  group('daysUntil', () {
    test('returns 0 for the same calendar day', () {
      final date = DateTime(2024, 3, 15, 10, 30); // time component is irrelevant
      expect(date.daysUntil(DateTime(2024, 3, 15, 22, 0)), 0);
    });

    test('returns positive value for a future date', () {
      final from = DateTime(2024, 1, 1);
      final to = DateTime(2024, 1, 11);
      expect(from.daysUntil(to), 10);
    });

    test('returns negative value for a past date', () {
      final from = DateTime(2024, 6, 20);
      final to = DateTime(2024, 6, 15);
      expect(from.daysUntil(to), -5);
    });

    test('handles month boundaries correctly', () {
      final from = DateTime(2024, 1, 31);
      final to = DateTime(2024, 2, 1);
      expect(from.daysUntil(to), 1);
    });

    test('handles year boundaries correctly', () {
      final from = DateTime(2023, 12, 31);
      final to = DateTime(2024, 1, 1);
      expect(from.daysUntil(to), 1);
    });

    test('strips time component — same day at different times is 0', () {
      final morning = DateTime(2024, 5, 10, 1, 0);
      final evening = DateTime(2024, 5, 10, 23, 59);
      expect(morning.daysUntil(evening), 0);
      expect(evening.daysUntil(morning), 0);
    });

    test('handles leap-year day (Feb 29)', () {
      final from = DateTime(2024, 2, 28);
      final to = DateTime(2024, 3, 1);
      expect(from.daysUntil(to), 2); // 2024 is a leap year
    });
  });

  group('withoutTimeUtc', () {
    test('returns a UTC DateTime at midnight', () {
      final dt = DateTime(2024, 7, 4, 15, 30, 45);
      final result = dt.withoutTimeUtc;
      expect(result.isUtc, isTrue);
      expect(result.year, 2024);
      expect(result.month, 7);
      expect(result.day, 4);
      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.second, 0);
      expect(result.millisecond, 0);
    });

    test('preserves the calendar date', () {
      final dt = DateTime(2024, 12, 31, 23, 59, 59);
      final result = dt.withoutTimeUtc;
      expect(result.day, 31);
      expect(result.month, 12);
      expect(result.year, 2024);
    });

    test('is idempotent on a UTC midnight DateTime', () {
      final midnight = DateTime.utc(2024, 3, 1);
      expect(midnight.withoutTimeUtc, midnight);
    });
  });

  group('firstDayOfMonth', () {
    test('returns the 1st of the same month and year', () {
      final dt = DateTime(2024, 8, 25);
      final result = dt.firstDayOfMonth;
      expect(result.year, 2024);
      expect(result.month, 8);
      expect(result.day, 1);
    });

    test('already on the 1st returns the 1st', () {
      final dt = DateTime(2024, 1, 1);
      expect(dt.firstDayOfMonth.day, 1);
    });

    test('works for December', () {
      final dt = DateTime(2023, 12, 31);
      final result = dt.firstDayOfMonth;
      expect(result.month, 12);
      expect(result.day, 1);
    });

    test('strips time component', () {
      final dt = DateTime(2024, 6, 15, 14, 30);
      final result = dt.firstDayOfMonth;
      expect(result.hour, 0);
      expect(result.minute, 0);
    });
  });

  group('startOfWeek', () {
    // 2024-04-15 is a Monday (DateTime.monday == 1)
    final monday = DateTime(2024, 4, 15);
    // 2024-04-21 is a Sunday
    final sunday = DateTime(2024, 4, 21);
    // 2024-04-17 is a Wednesday
    final wednesday = DateTime(2024, 4, 17);

    group('default start = WeekDays.monday', () {
      test('Monday returns itself (UTC midnight)', () {
        final result = monday.startOfWeek();
        expect(result, DateTime.utc(2024, 4, 15));
      });

      test('Wednesday returns the preceding Monday', () {
        final result = wednesday.startOfWeek();
        expect(result, DateTime.utc(2024, 4, 15));
      });

      test('Sunday returns the preceding Monday', () {
        final result = sunday.startOfWeek();
        expect(result, DateTime.utc(2024, 4, 15));
      });

      test('result is UTC midnight', () {
        final result = wednesday.startOfWeek();
        expect(result.isUtc, isTrue);
        expect(result.hour, 0);
        expect(result.minute, 0);
      });
    });

    group('start = WeekDays.sunday', () {
      test('Sunday returns itself', () {
        final result = sunday.startOfWeek(start: WeekDays.sunday);
        expect(result, DateTime.utc(2024, 4, 21));
      });

      test('Monday returns the preceding Sunday', () {
        final result = monday.startOfWeek(start: WeekDays.sunday);
        expect(result, DateTime.utc(2024, 4, 14));
      });

      test('Wednesday returns the preceding Sunday', () {
        final result = wednesday.startOfWeek(start: WeekDays.sunday);
        expect(result, DateTime.utc(2024, 4, 14));
      });
    });

    group('start = WeekDays.saturday', () {
      // 2024-04-13 is a Saturday
      final saturday = DateTime(2024, 4, 13);

      test('Saturday returns itself', () {
        final result = saturday.startOfWeek(start: WeekDays.saturday);
        expect(result, DateTime.utc(2024, 4, 13));
      });

      test('Monday returns the preceding Saturday', () {
        final result = monday.startOfWeek(start: WeekDays.saturday);
        expect(result, DateTime.utc(2024, 4, 13));
      });
    });

    test('strips time component from input', () {
      final dt = DateTime(2024, 4, 17, 23, 59, 59); // Wednesday with time
      final result = dt.startOfWeek();
      expect(result, DateTime.utc(2024, 4, 15));
    });
  });

  group('weeksUntil', () {
    test('same week returns 1', () {
      final monday = DateTime(2024, 4, 15);
      final friday = DateTime(2024, 4, 19);
      expect(monday.weeksUntil(friday), 1);
    });

    test('next week returns 2', () {
      final monday = DateTime(2024, 4, 15);
      final nextMonday = DateTime(2024, 4, 22);
      expect(monday.weeksUntil(nextMonday), 2);
    });

    test('same day returns 1', () {
      final date = DateTime(2024, 4, 15);
      expect(date.weeksUntil(date), 1);
    });

    test('two full weeks apart returns 3', () {
      final from = DateTime(2024, 4, 15); // Monday
      final to = DateTime(2024, 4, 29); // Monday two weeks later
      expect(from.weeksUntil(to), 3);
    });
  });
}
