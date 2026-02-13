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

class CalendarSelectionSheet extends StatefulWidget {
  final AppIntl intl;

  const CalendarSelectionSheet({super.key, required this.intl});

  @override
  State<CalendarSelectionSheet> createState() => _CalendarSelectionSheetState();
}

class _CalendarSelectionSheetState extends State<CalendarSelectionSheet> {
  String selectedCalendarId = '';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: CalendarService.nativeCalendars,
      builder: (context, AsyncSnapshot<UnmodifiableListView<Calendar>> calendars) {
        if (calendars.error != null) {
          return _permissionDeniedContent(context);
        }

        if (!calendars.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = calendars.data!
            .map<DropdownMenuItem<String>>(
              (calendar) => DropdownMenuItem(value: calendar.name, child: Text(calendar.name!)),
            )
            .toList();

        items.add(DropdownMenuItem(value: "new", child: Text(widget.intl.calendar_new)));

        selectedCalendarId = selectedCalendarId.isEmpty ? items.first.value! : selectedCalendarId;

        return Container(
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(color: context.theme.appColors.modalTitle),
                child: Column(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          height: 5,
                          width: 50,
                          decoration: BoxDecoration(
                            color: context.theme.appColors.modalHandle,
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        widget.intl.calendar_export,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                left: false,
                right: false,
                child: Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 32.0, bottom: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12.0,
                    children: [
                      Text(widget.intl.calendar_export_question),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: context.theme.appBarTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton(
                          value: selectedCalendarId,
                          underline: const SizedBox(),
                          isExpanded: true,
                          items: items,
                          onChanged: (value) {
                            setState(() {
                              selectedCalendarId = value!;
                            });
                          },
                        ),
                      ),
                      if (selectedCalendarId == "new") ...[
                        const SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(labelText: widget.intl.calendar_name),
                          onChanged: (value) {
                            selectedCalendarId = value;
                          },
                        ),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(widget.intl.calendar_cancel_button),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(onPressed: _export, child: Text(widget.intl.calendar_export_button)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _export() {
    if (selectedCalendarId.isEmpty) {
      Fluttertoast.showToast(
        msg: widget.intl.calendar_select,
        backgroundColor: AppPalette.etsLightRed,
        textColor: AppPalette.grey.black,
      );
      return;
    }

    Navigator.pop(context);

    final courseRepository = locator<CourseRepository>();

    CalendarService.export(courseRepository.coursesActivities!, selectedCalendarId).then((success) {
      Fluttertoast.showToast(
        msg: success ? widget.intl.calendar_export_success : widget.intl.calendar_export_error,
        backgroundColor: success ? AppPalette.gradeGoodMax : AppPalette.etsLightRed,
        textColor: AppPalette.grey.black,
      );
    });
  }

  Widget _permissionDeniedContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.intl.calendar_permission_denied_modal_title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(widget.intl.calendar_permission_denied),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(onPressed: () => Navigator.pop(context), child: Text(widget.intl.calendar_cancel_button)),
        ),
      ],
    );
  }
}
