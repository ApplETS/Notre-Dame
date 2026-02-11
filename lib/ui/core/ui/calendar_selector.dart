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
import 'package:notredame/ui/core/themes/app_theme.dart';

class CalendarSelectionWidget extends StatelessWidget {
  final AppIntl intl;

  const CalendarSelectionWidget({super.key, required this.intl});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: CalendarService.nativeCalendars,
      builder: (context, AsyncSnapshot<UnmodifiableListView<Calendar>> calendars) {
        if (calendars.error != null) {
          return _lackingPermissionsDialog(context);
        }
        if (!calendars.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = calendars.data!
            .map<DropdownMenuItem<String>>(
              (Calendar value) => DropdownMenuItem(value: value.name, child: Text(value.name!)),
            )
            .toList();
        items.add(DropdownMenuItem(value: "new", child: Text(intl.calendar_new)));
        String selectedCalendarId = items[0].value ?? '';
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(intl.calendar_export),
              content: Column(
                spacing: 6.0,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(intl.calendar_export_question),
                  Container(
                    decoration: BoxDecoration(color: context.theme.appBarTheme.backgroundColor, borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: DropdownButton(
                      items: items,
                      value: selectedCalendarId,
                      underline: SizedBox(),
                      onChanged: (calendar) {
                        setState(() {
                          selectedCalendarId = calendar!;
                        });
                      },
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      return selectedCalendarId == "new"
                          ? TextField(
                              onChanged: (value) {
                                selectedCalendarId = value;
                              },
                              decoration: InputDecoration(labelText: intl.calendar_name),
                            )
                          : Container();
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(intl.calendar_cancel_button)),
                TextButton(
                  onPressed: () {
                    if (selectedCalendarId.isEmpty) {
                      Fluttertoast.showToast(
                        msg: intl.calendar_select,
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
                          msg: intl.calendar_export_success,
                          backgroundColor: AppPalette.gradeGoodMax,
                          textColor: AppPalette.grey.black,
                        );
                      } else {
                        Fluttertoast.showToast(
                          msg: intl.calendar_export_error,
                          backgroundColor: AppPalette.etsLightRed,
                          textColor: AppPalette.grey.black,
                        );
                      }
                    });
                  },
                  child: Text(intl.calendar_export_button),
                ),
              ],
            );
          },
        );
      },
    );
  }

  AlertDialog _lackingPermissionsDialog(BuildContext context) {
    return AlertDialog(
      title: Text(intl.calendar_permission_denied_modal_title),
      content: Text(intl.calendar_permission_denied),
      actions: [
        TextButton(
          child: Text(intl.calendar_cancel_button),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
