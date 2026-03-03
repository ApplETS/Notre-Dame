// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';

// Project imports:
import 'package:notredame/data/models/event_data.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/core/ui/modal_bottom_sheet_layout.dart';

class CalendarEventTile extends StatefulWidget {
  final EventData event;
  final EdgeInsets? padding;

  const CalendarEventTile({super.key, required this.event, this.padding});

  @override
  State<CalendarEventTile> createState() => _CalendarEventTileState();
}

class _CalendarEventTileState extends State<CalendarEventTile> {
  void _showTileInfo() {
    final courseLocation = widget.event.locations?.join(", ");
    final courseType = widget.event.activityName;
    final teacherName = widget.event.teacherName;
    final startTime = "${widget.event.startTime.hour}:${widget.event.startTime.minute.toString().padLeft(2, '0')}";
    final endTime = "${widget.event.endTime.hour}:${widget.event.endTime.minute.toString().padLeft(2, '0')}";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      builder: (context) {
        return ModalBottomSheetLayout(
          title: Column(
            children: [
              Text(
                widget.event.group ?? widget.event.courseAcronym,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.event.courseName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12.0,
            children: [
              _sheetRow(
                "${AppIntl.of(context)!.schedule_calendar_from_time} "
                "$startTime "
                "${AppIntl.of(context)!.schedule_calendar_to_time} "
                "$endTime",
                Icons.access_time,
              ),
              if (courseLocation != null) _sheetRow(courseLocation, Icons.location_pin),
              if (courseType != null) _sheetRow(courseType, Icons.book),
              if (teacherName != null)
                _sheetRow("${AppIntl.of(context)!.schedule_calendar_by} $teacherName", Icons.person),
            ],
          ),
        );
      },
    );
  }

  Row _sheetRow(String text, IconData icon) {
    return Row(
      spacing: 8.0,
      children: [
        Icon(icon),
        Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final aspectRatio = width / height;
        // If the card is 4 times wider than tall and is smaller than 60 in height
        final wideLayout = aspectRatio > 3 || height < 60;
        // If both dimensions are smaller than 80 or a dimension is smaller than 40
        final isSmall = max(width, height) < 80 || min(width, height) < 40;

        final description = widget.event.calendarDescription(!wideLayout);

        if (isSmall || description == null) {
          return Card(
            color: widget.event.color,
            clipBehavior: Clip.hardEdge,
            margin: EdgeInsets.all(3.0),
            child: InkWell(
              onTap: _showTileInfo,
              child: Center(
                child: RotatedBox(
                  quarterTurns: width > 40 ? 0 : 1,
                  child: AutoSizeText(
                    widget.event.courseAcronym,
                    minFontSize: 8,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppPalette.grey.white),
                  ),
                ),
              ),
            ),
          );
        }

        return Card(
          color: widget.event.color,
          clipBehavior: Clip.hardEdge,
          margin: EdgeInsets.all(3.0),
          child: InkWell(
            onTap: _showTileInfo,
            child: Flex(
              direction: wideLayout ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: wideLayout ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: wideLayout ? min(70, width / 2.5) : null,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: const Color.fromRGBO(0, 0, 0, 0.2)),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 6.0),
                        child: AutoSizeText(
                          widget.event.courseAcronym,
                          minFontSize: 8,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppPalette.grey.white, height: 1),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: widget.padding,
                    child: AutoSizeText(
                      description,
                      minFontSize: 8,
                      maxLines: widget.event.locations!.length + 1,
                      style: TextStyle(color: AppPalette.grey.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
