// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Project imports:
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/calendar_utils.dart';
import 'package:notredame/utils/locator.dart';

class CalendarSelectionWidget extends StatelessWidget {
  final AppIntl translations;
  const CalendarSelectionWidget({super.key, required this.translations});

  @override
  Widget build(BuildContext context) {
    bool error = false;

    const snackBar = SnackBar(
      content: Text("Pour cette fonctionnalité, tu dois autoriser l'acces complet au calendrier"),
    );

    return FutureBuilder(
      future: CalendarUtils.nativeCalendars.catchError((e) {error = true;}),
      builder:
          (context, AsyncSnapshot<UnmodifiableListView<Calendar>> calendars) {
        if (error == true) {
          return AlertDialog(
          title: const Text('Permission Refusée'),
          content: const Text("Vous n'avez pas accordé la permission d'accéder à votre calendrier. Veuillez l'activer dans les paramètres système de l'application."),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
        }

        if (!calendars.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final items = calendars.data!
            .map<DropdownMenuItem<String>>(
              (Calendar value) => DropdownMenuItem<String>(
                value: value.name,
                child: Text(value.name!),
              ),
            )
            .toList();
        items.add(
          DropdownMenuItem<String>(
            value: "new",
            child: Text(translations.calendar_new),
          ),
        );
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
                              decoration: InputDecoration(
                                labelText: translations.calendar_name,
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
                    if (selectedCalendarId.isEmpty) {
                      Fluttertoast.showToast(
                        msg: translations.calendar_select,
                        backgroundColor: AppTheme.etsLightRed,
                        textColor: AppTheme.etsBlack,
                      );
                      return;
                    }
                    Navigator.of(context).pop();

                    final CourseRepository courseRepository =
                        locator<CourseRepository>();

                    final result = CalendarUtils.export(
                      courseRepository.coursesActivities!,
                      selectedCalendarId,
                    );

                    result.then((value) {
                      if (value) {
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
                    });
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
