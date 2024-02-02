import 'dart:collection';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/utils/calendar_utils.dart';
import 'package:notredame/locator.dart';

class CalendarSelectionWidget extends StatelessWidget {
  const CalendarSelectionWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: CalendarUtils.nativeCalendars,
      builder:
          (context, AsyncSnapshot<UnmodifiableListView<Calendar>> calendars) {
        if (!calendars.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final items = calendars.data
            .map<DropdownMenuItem<String>>(
              (Calendar value) => DropdownMenuItem<String>(
                value: value.name,
                child: Text(value.name),
              ),
            )
            .toList();
        items.add(
          DropdownMenuItem<String>(
            value: "new",
            // TODO TRANSLATION
            // child: Text("New calendar"),
            child: Text(AppIntl.of(context).calendar_new),
          ),
        );
        String selectedCalendarId = items[0].value;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              // TODO TRANSLATION
              // title: const Text('Export to calendar'),
              title: Text(AppIntl.of(context).calendar_export),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TODO TRANSLATION
                  // const Text('Which calendar do you want to export to?'),
                  Text(AppIntl.of(context).calendar_export_question),
                  DropdownButton<String>(
                    items: items,
                    value: selectedCalendarId,
                    onChanged: (calendar) {
                      setState(() {
                        selectedCalendarId = calendar;
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
                              // todo translation
                              decoration: InputDecoration(
                                // labelText: 'Calendar name',
                                labelText: AppIntl.of(context).calendar_name,
                              ),
                            )
                          : const SizedBox(height: 10);
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedCalendarId == null ||
                        selectedCalendarId.isEmpty) {
                      Fluttertoast.showToast(
                        // TODO TRANSLATION
                        // msg: 'Please select a calendar',
                        msg: AppIntl.of(context).calendar_select,
                        backgroundColor: AppTheme.etsLightRed,
                        textColor: AppTheme.etsBlack,
                      );
                      return;
                    }
                    Navigator.of(context).pop();
                    final CourseRepository courseRepository =
                        locator<CourseRepository>();
                    CalendarUtils.export(
                        courseRepository.coursesActivities, selectedCalendarId);
                  },
                  child: const Text('Export'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
