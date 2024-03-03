import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/core/utils/calendar_utils.dart';

class CalendarSelectionViewModel {
  final AppIntl translations;
  late String selectedCalendarId;

  CalendarSelectionViewModel({required this.translations}) {
    selectedCalendarId = "";
  }

  Future<void> exportEvent(BuildContext context, Event? event) async {
    if (selectedCalendarId.isEmpty) {
      Fluttertoast.showToast(
        msg: translations.calendar_select,
        backgroundColor: AppTheme.etsLightRed,
        textColor: AppTheme.etsBlack,
      );
      return;
    }

    Navigator.of(context).pop();
    final result = await CalendarUtils.exportEvent(event, selectedCalendarId);
    if (result) {
      Fluttertoast.showToast(
        msg: translations.calendar_export_success,
        backgroundColor: AppTheme.gradeGoodMax,
        textColor: AppTheme.etsBlack,
      );
    } else {
      Fluttertoast.showToast(
        msg: translations.calendar_export_error,
        backgroundColor: AppTheme.etsLightRed,
        textColor: AppTheme.etsBlack,
      );
    }
  }
}
