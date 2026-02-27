// Package imports:
import 'package:calendar_view/calendar_view.dart';

mixin DateUtils {
  static DateTime getFirstdayOfWeek(DateTime currentDate) {
    return currentDate.subtract(Duration(days: currentDate.weekday % 7)).withoutTime;
  }

  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month);
  }

  static DateTime dateOnly(DateTime date) => DateTime.utc(date.year, date.month, date.day);

  static DateTime startOfWeek(DateTime date) {
    final dateOnlyDate = dateOnly(date);
    return dateOnlyDate.subtract(Duration(days: date.weekday - 1));
  }

  static int daysBetween(DateTime start, DateTime end) => dateOnly(end).difference(dateOnly(start)).inDays;

  static int monthsRemaining(DateTime endDate, DateTime now) {
    final months = (endDate.year - now.year) * 12 + (endDate.month - now.month);
    return months < 0 ? 0 : months;
  }

  static int weeksCompleted(DateTime startDate, DateTime now) {
    final startWeekMonday = startOfWeek(startDate);
    final currentWeekMonday = startOfWeek(now);
    return (daysBetween(startWeekMonday, currentWeekMonday) ~/ 7) + 1;
  }

  static int weeksRemaining(DateTime endDate, DateTime now) {
    final today = dateOnly(now);
    final end = dateOnly(endDate);

    if (end.isBefore(today)) return -1;

    return daysBetween(startOfWeek(today), startOfWeek(end)) ~/ 7 + 1;
  }
}
