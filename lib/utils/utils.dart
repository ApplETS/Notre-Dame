// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';

mixin Utils {
  static double getGradeInPercentage(double? grade, double? maxGrade) {
    if (grade == null || maxGrade == null || grade == 0.0 || maxGrade == 0.0) {
      return 0.0;
    }

    return double.parse(((grade / maxGrade) * 100).toStringAsFixed(1));
  }

  static String getMessageByLocale(BuildContext context, String fr, String en) {
    return Localizations.localeOf(context).toString() == "fr" ? fr : en;
  }

  static DateTime getFirstdayOfWeek(DateTime currentDate) {
    return currentDate
        .subtract(Duration(days: currentDate.weekday % 7))
        .withoutTime;
  }

  static DateTime getCurrentSundayOfWeek(DateTime currentDate) {
    return currentDate
        .add(Duration(days: (DateTime.saturday - currentDate.weekday + 7) % 7));
  }

  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month);
  }
}
