// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/utils.dart';

// Project imports:

Widget newsDateSection(BuildContext context, DateTime publishedDate,
    DateTime eventStartDate, DateTime? eventEndDate) {
  final String locale = Localizations.localeOf(context).toString();
  final String formattedPublishedDate =
      DateFormat('d MMMM yyyy', locale).format(publishedDate);

  late String formattedEventDate;

  final bool sameMonthAndYear = eventEndDate?.month == eventStartDate.month &&
      eventEndDate?.year == eventStartDate.year;
  final bool sameDayMonthAndYear =
      eventEndDate?.day == eventStartDate.day && sameMonthAndYear;

  if (eventEndDate == null || sameDayMonthAndYear) {
    formattedEventDate =
        DateFormat('d MMMM yyyy', locale).format(eventStartDate);
  } else {
    if (sameMonthAndYear) {
      formattedEventDate =
          '${DateFormat('d', locale).format(eventStartDate)} - ${DateFormat('d MMMM yyyy', locale).format(eventEndDate)}';
    } else {
      formattedEventDate =
          '${DateFormat('d MMMM yyyy', locale).format(eventStartDate)} -\n${DateFormat('d MMMM yyyy', locale).format(eventEndDate)}';
    }
  }

  return Padding(
    padding: const EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedPublishedDate,
              style: TextStyle(
                  color: Utils.getColorByBrightness(
                      context, Colors.black, Colors.white)),
            ),
            const SizedBox(height: 12.0),
          ],
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Utils.getColorByBrightness(
                      context, AppTheme.darkThemeAccent, AppTheme.etsDarkGrey),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.event, size: 20.0, color: Colors.white),
              ),
              Flexible(
                  child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppIntl.of(context)!.news_event_date,
                      style: TextStyle(
                          color: Utils.getColorByBrightness(
                              context, Colors.black, AppTheme.etsLightGrey)),
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      formattedEventDate,
                      style: TextStyle(
                          color: Utils.getColorByBrightness(
                              context, AppTheme.darkThemeAccent, Colors.white)),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    ),
  );
}
