// Flutter imports:
import 'package:flutter/material.dart';

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
    final tempDate =
        currentDate.subtract(Duration(days: currentDate.weekday % 7));
    return DateTime(tempDate.year, tempDate.month, tempDate.day);
  }

  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month);
  }
}
