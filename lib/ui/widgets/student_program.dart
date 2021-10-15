// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MODEL
import 'package:notredame/core/models/program.dart';

// OTHER
import 'package:notredame/ui/utils/app_theme.dart';

class StudentProgram extends StatelessWidget {
  final Program _program;

  const StudentProgram(this._program);

  @override
  Widget build(BuildContext context) {
    final List<String> dataTitles = [
      AppIntl.of(context).profile_code_program,
      AppIntl.of(context).profile_average_program,
      AppIntl.of(context).profile_number_accumulated_credits_program,
      AppIntl.of(context).profile_number_registered_credits_program,
      AppIntl.of(context).profile_number_completed_courses_program,
      AppIntl.of(context).profile_number_failed_courses_program,
      AppIntl.of(context).profile_number_equivalent_courses_program,
      AppIntl.of(context).profile_status_program
    ];
    final List<String> dataFetched = [
      _program.code,
      _program.average,
      _program.accumulatedCredits,
      _program.registeredCredits,
      _program.completedCourses,
      _program.failedCourses,
      _program.equivalentCourses,
      _program.status
    ];
    return Column(
      children: [
        const Divider(
          thickness: 2,
          indent: 10,
          endIndent: 10,
        ),
        ListTile(
          title: Text(
            _program.name,
            style: const TextStyle(color: AppTheme.etsLightRed),
          ),
        ),
        ListView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(dataTitles[index]),
                trailing: Text(dataFetched[index]),
              );
            },
            itemCount: dataTitles.length)
      ],
    );
  }
}
