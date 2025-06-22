// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';

mixin Utils {
  static double? getGradeInPercentage(double? grade, double? maxGrade) {
    if (grade == null || maxGrade == null) {
      return null;
    }

    if (grade == 0.0 || maxGrade == 0.0) {
      return 0.0;
    }

    return double.parse(((grade / maxGrade) * 100).toStringAsFixed(1));
  }

  static String getMessageByLocale(BuildContext context, String fr, String en) {
    return Localizations.localeOf(context).toString() == "fr" ? fr : en;
  }

  static DateTime getFirstdayOfWeek(DateTime currentDate) {
    return currentDate.subtract(Duration(days: currentDate.weekday % 7)).withoutTime;
  }

  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month);
  }

  static String validateResultWithPercentage(
    BuildContext context,
    double? result,
    double? maxGrade,
    double percentage,
  ) {
    if (result == null || maxGrade == null) {
      return AppIntl.of(context)!.grades_not_available;
    }

    final String formattedResult = result.toStringAsFixed(2);
    return AppIntl.of(context)!.grades_grade_with_percentage(double.parse(formattedResult), maxGrade, percentage);
  }

  static String getOrdinal(int number, String languageCode) {
    if (languageCode == 'en') {
      if (number % 100 >= 11 && number % 100 <= 13) {
        return '${number}th';
      }
      switch (number % 10) {
        case 1:
          return '${number}st';
        case 2:
          return '${number}nd';
        case 3:
          return '${number}rd';
        default:
          return '${number}th';
      }
    } else {
      if (number == 1) {
        return '${number}re';
      } else {
        return '${number}e';
      }
    }
  }
}
