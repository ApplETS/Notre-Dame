// Flutter imports:
import 'package:flutter/material.dart';

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
}
