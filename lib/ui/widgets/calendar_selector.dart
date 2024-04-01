import 'package:flutter/material.dart';
import 'package:notredame/core/viewmodels/calendar_selection_viewmodel.dart';

class CalendarSelectionWidget extends StatelessWidget {
  final CalendarSelectionViewModel viewModel;

  const CalendarSelectionWidget({Key? key, required this.viewModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: viewModel.fetchCalendars(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final items = viewModel.getDropdownItems();
        items.add(
          DropdownMenuItem<String>(
            value: "new",
            child: Text(viewModel.translations.calendar_new),
          ),
        );
        viewModel.selectedCalendarId ??= items[0].value;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(viewModel.translations.calendar_export),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(viewModel.translations.calendar_export_question),
                  DropdownButton<String>(
                    items: items,
                    value: viewModel.selectedCalendarId,
                    onChanged: (calendar) {
                      setState(() {
                        viewModel.selectedCalendarId = calendar;
                      });
                    },
                  ),
                  Builder(
                    builder: (context) {
                      return viewModel.selectedCalendarId == "new"
                          ? TextField(
                              onChanged: (value) {
                                viewModel.selectedCalendarId = value;
                              },
                              decoration: InputDecoration(
                                labelText: viewModel.translations.calendar_name,
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
                  child: Text(viewModel.translations.calendar_cancel),
                ),
                TextButton(
                  onPressed: () => viewModel.exportCalendar(context),
                  child: Text(viewModel.translations.calendar_export),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
