// Package imports:
import 'package:calendar_view/calendar_view.dart';

extension DateTimeExtensionsTest on DateTime {
  int daysUntil(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day).difference(DateTime.utc(year, month, day)).inDays;

  /// Returns a UTC midnight DateTime for the given [date]'s calendar day.
  /// Both sides of a comparison must be normalized to avoid timezone mismatches.
  DateTime get withoutTimeUtc => DateTime.utc(year, month, day);

  int weeksUntil(DateTime date) {
    final thisMonday = withoutTimeUtc.subtract(Duration(days: weekday - 1));
    final dateMonday = date.withoutTimeUtc.subtract(Duration(days: date.weekday - 1));
    return dateMonday.difference(thisMonday).inDays ~/ 7 + 1;
  }

  DateTime get firstDayOfMonth => DateTime(year, month);

  DateTime startOfWeek({WeekDays start = WeekDays.monday}) {
    final daysFromStart = (weekday - 1 - start.index + 7) % 7;
    return withoutTimeUtc.subtract(Duration(days: daysFromStart));
  }
}
