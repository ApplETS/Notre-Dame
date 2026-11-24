// ignore_for_file: deprecated_member_use

// Flutter imports:
import 'package:flutter/material.dart' as legacy;

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:notredame/ui/core/themes/app_theme.dart';

/// Exposes the current `material_ui` theme and localizations to widgets of dependencies that
/// still use `package:flutter/material.dart` (calendar_view, table_calendar, skeletonizer, ...),
/// and adds the calendar_view theme extensions, which can't be stored in a `material_ui` [ThemeData].
///
/// TODO remove when all dependencies use `material_ui`.
class LegacyMaterialBridge extends StatelessWidget {
  final Widget child;

  const LegacyMaterialBridge({super.key, required this.child});

  @override
  Widget build(BuildContext context) => MaterialUiCompatibilityBridge(
    child: Builder(
      builder: (context) {
        final legacyTheme = legacy.Theme.of(context);
        return legacy.Theme(
          data: legacyTheme.copyWith(
            extensions: [...legacyTheme.extensions.values, ..._calendarExtensions(Theme.of(context))],
          ),
          child: child,
        );
      },
    ),
  );

  static List<legacy.ThemeExtension<dynamic>> _calendarExtensions(ThemeData theme) {
    final appColors = theme.appColors;
    final isDark = theme.brightness == Brightness.dark;
    final textColor = (isDark ? ThemeData.dark() : ThemeData.light()).textTheme.bodyMedium!.color;

    return [
      (isDark ? MonthViewThemeData.dark() : MonthViewThemeData.light()).copyWith(
        cellBorderColor: appColors.scheduleLine,
        headerBackgroundColor: appColors.appBar,
        headerTextColor: textColor,
        headerIconColor: textColor,
        weekDayTileColor: appColors.appBar,
      ),
      (isDark ? WeekViewThemeData.dark() : WeekViewThemeData.light()).copyWith(
        hourLineColor: appColors.scheduleLine,
        verticalLinesColor: appColors.scheduleLine,
        liveIndicatorColor: textColor,
        pageBackgroundColor: Colors.transparent,
        headerBackgroundColor: appColors.appBar,
        headerTextColor: textColor,
        headerIconColor: textColor,
        borderColor: appColors.scheduleLine,
      ),
      (isDark ? DayViewThemeData.dark() : DayViewThemeData.light()).copyWith(
        hourLineColor: appColors.scheduleLine,
        pageBackgroundColor: Colors.transparent,
        liveIndicatorColor: textColor,
      ),
    ];
  }
}

/// Provides a transparent legacy `Material` ancestor to widgets of dependencies that still use
/// `package:flutter/material.dart` and need one (e.g. their `InkWell`s), since `material_ui`
/// widgets such as `Scaffold` or `Card` don't provide it.
class LegacyMaterialScope extends StatelessWidget {
  final Widget child;

  const LegacyMaterialScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) => legacy.Material(type: legacy.MaterialType.transparency, child: child);
}
