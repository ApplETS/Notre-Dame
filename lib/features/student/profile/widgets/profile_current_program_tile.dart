import 'package:ets_api_clients/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/utils/app_theme.dart';

Column getCurrentProgramTile(List<Program> programList, BuildContext context) {
  if (programList.isNotEmpty) {
    final program = programList.last;

    final List<String> dataTitles = [
      AppIntl.of(context)!.profile_code_program,
      AppIntl.of(context)!.profile_average_program,
      AppIntl.of(context)!.profile_number_accumulated_credits_program,
      AppIntl.of(context)!.profile_number_registered_credits_program,
      AppIntl.of(context)!.profile_number_completed_courses_program,
      AppIntl.of(context)!.profile_number_failed_courses_program,
      AppIntl.of(context)!.profile_number_equivalent_courses_program,
      AppIntl.of(context)!.profile_status_program
    ];

    final List<String> dataFetched = [
      program.code,
      program.average,
      program.accumulatedCredits,
      program.registeredCredits,
      program.completedCourses,
      program.failedCourses,
      program.equivalentCourses,
      program.status
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          child: Text(
            program.name,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.etsLightRed),
          ),
        ),
        ...List<Widget>.generate(dataTitles.length, (index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(dataTitles[index]),
                Text(dataFetched[index]),
              ],
            ),
          );
        }),
      ],
    );
  } else {
    return const Column();
  }
}
