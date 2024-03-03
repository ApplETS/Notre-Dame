import 'dart:collection';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';

import 'package:notredame/core/utils/calendar_utils.dart';
import 'package:notredame/core/viewmodels/calendar_selection_viewmodel.dart';
import 'package:notredame/locator.dart';

class CalendarSelectionWidget extends StatelessWidget {
  final AppIntl translations;
  final Event? event;
  const CalendarSelectionWidget(
      {Key? key, this.event, required this.translations})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: CalendarUtils.nativeCalendars,
      builder:
          (context, AsyncSnapshot<UnmodifiableListView<Calendar>?> calendars) {
        if (!calendars.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final items = calendars.data!
            .map<DropdownMenuItem<String>>(
              (Calendar value) => DropdownMenuItem<String>(
                value: value.name,
                child: Text(value.name ?? ""),
              ),
            )
            .toList();
        items.add(
          DropdownMenuItem<String>(
            value: "new",
            child: Text(translations.calendar_new),
          ),
        );

        final viewModel =
            CalendarSelectionViewModel(translations: translations);

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(translations.calendar_export),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(translations.calendar_export_question),
                  /*DropdownButton<String>(
                    items: items,
                    value: viewModel.selectedCalendarId,
                    onChanged: (calendar) {
                      setState(() {
                        viewModel.selectedCalendarId = calendar!;
                      });
                    },
                  ),*/
                  Builder(
                    builder: (context) {
                      return viewModel.selectedCalendarId == "new"
                          ? TextField(
                              onChanged: (value) {
                                viewModel.selectedCalendarId = value;
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
                  onPressed: () => viewModel.exportEvent(context, event),
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
