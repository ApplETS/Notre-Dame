// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

mixin Utils {
  /// Used to open a url
  static Future<void> launchURL(String url, AppIntl intl) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Fluttertoast.showToast(msg: intl.error);
      throw 'Could not launch $url';
    }
  }

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

  static Color? getColorByBrightnessNullable(
      BuildContext context, Color? lightColor, Color? darkColor) {
    return Theme.of(context).brightness == Brightness.light
        ? lightColor
        : darkColor;
  }

  static bool isDarkTheme(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Get first day of the week depending on startingDay which corresponds to weekday
  static DateTime getFirstDayOfCurrentWeek(
      DateTime currentDate, StartingDayOfWeek startingDay) {
    var firstDayOfWeek = DateTime.now();
    switch (startingDay) {
      case StartingDayOfWeek.monday:
        final tempDate =
            currentDate.subtract(Duration(days: currentDate.weekday - 1));
        firstDayOfWeek = DateTime(tempDate.year, tempDate.month, tempDate.day);
        break;
      case StartingDayOfWeek.saturday:
        final tempDate = currentDate.subtract(Duration(
            days: currentDate.weekday == 6 || currentDate.weekday == 7
                ? currentDate.weekday - 6
                : currentDate.weekday + 1));
        firstDayOfWeek = DateTime(tempDate.year, tempDate.month, tempDate.day);
        break;
      // Sunday as default
      default:
        final tempDate =
            currentDate.subtract(Duration(days: currentDate.weekday % 7));
        firstDayOfWeek = DateTime(tempDate.year, tempDate.month, tempDate.day);
    }
    return firstDayOfWeek;
  }
}
