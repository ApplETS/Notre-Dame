// Flutter imports:
import 'package:flutter/material.dart';

mixin Utils {
  static double getGradeInPercentage(double? grade, double? maxGrade) {
    if (grade == null || maxGrade == null || grade == 0.0 || maxGrade == 0.0) {
      return 0.0;
    }

    return double.parse(((grade / maxGrade) * 100).toStringAsFixed(1));
  }

  static Color getColorByBrightness(
      BuildContext context, Color lightColor, Color darkColor) {
    return Theme.of(context).brightness == Brightness.light
        ? lightColor
        : darkColor;
  }

  static String getMessageByLocale(BuildContext context, String fr, String en) {
    return Localizations.localeOf(context).toString() == "fr" ? fr : en;
  }

  /// Get first day of the week depending on startingDay which corresponds to weekday
  static DateTime getFirstDayOfCurrentWeek(
      DateTime currentDate) {
    final tempDate = currentDate.subtract(Duration(days: currentDate.weekday % 7));
    return DateTime(tempDate.year, tempDate.month, tempDate.day);
  }
}
