// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:device_calendar/device_calendar.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Project imports:
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/services/calendar_service.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';

class CalendarSelectionWidget extends StatelessWidget {
  final AppIntl translations;
  const CalendarSelectionWidget({super.key, required this.translations});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: CalendarService.nativeCalendars,
      builder: (context, AsyncSnapshot<UnmodifiableListView<Calendar>> calendars) {
        if (calendars.error != null) {
          return lackingPermissionsDialog(context);
        }
        if (!calendars.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = calendars.data!
            .map<DropdownMenuItem<String>>(
              (Calendar value) => DropdownMenuItem<String>(value: value.name, child: Text(value.name!)),
            )
            .toList();
        items.add(DropdownMenuItem<String>(value: "new", child: Text(translations.calendar_new)));
        String selectedCalendarId = items[0].value ?? '';
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(translations.calendar_export),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(translations.calendar_export_question),
                  DropdownButton<String>(
                    items: items,
                    value: selectedCalendarId,
                    onChanged: (calendar) {
                      setState(() {
                        selectedCalendarId = calendar!;
                      });
                    },
                  ),
                  Builder(
                    builder: (context) {
                      return selectedCalendarId == "new"
                          ? TextField(
                              onChanged: (value) {
                                selectedCalendarId = value;
                              },
                              decoration: InputDecoration(labelText: translations.calendar_name),
                            )
                          : const SizedBox(height: 10);
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(translations.calendar_cancel_button),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedCalendarId.isEmpty) {
                      Fluttertoast.showToast(
                        msg: translations.calendar_select,
                        backgroundColor: AppPalette.etsLightRed,
                        textColor: AppPalette.grey.black,
                      );
                      return;
                    }
                    Navigator.of(context).pop();

                    final CourseRepository courseRepository = locator<CourseRepository>();

                    final result = CalendarService.export(courseRepository.coursesActivities!, selectedCalendarId);

                    result.then((value) {
                      if (value) {
                        Fluttertoast.showToast(
                          msg: translations.calendar_export_success,
                          backgroundColor: AppPalette.gradeGoodMax,
                          textColor: AppPalette.grey.black,
                        );
                      } else {
                        Fluttertoast.showToast(
                          msg: translations.calendar_export_error,
                          backgroundColor: AppPalette.etsLightRed,
                          textColor: AppPalette.grey.black,
                        );
                      }
                    });
                  },
                  child: Text(translations.calendar_export_button),
                ),
              ],
            );
          },
        );
      },
    );
  }

  AlertDialog lackingPermissionsDialog(BuildContext context) {
    return AlertDialog(
      title: Text(translations.calendar_permission_denied_modal_title),
      content: Text(translations.calendar_permission_denied),
      actions: <Widget>[
        TextButton(
          child: Text(translations.calendar_cancel_button),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
