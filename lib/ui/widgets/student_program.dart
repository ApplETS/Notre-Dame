// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:notredame/core/models/program.dart';

// OTHER
import 'package:notredame/generated/l10n.dart';
import 'package:notredame/ui/utils/app_theme.dart';

class StudentProgram extends StatelessWidget {
  final Program _program;

  const StudentProgram(this._program);

  @override
  Widget build(BuildContext context) {
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
        ListTile(
          title: Text(AppIntl.of(context).profile_code_program),
          trailing: Text(_program.code),
        ),
        ListTile(
          title: Text(AppIntl.of(context).profile_average_program),
          trailing: Text(_program.average),
        ),
        ListTile(
          title: Text(
              AppIntl.of(context).profile_number_accumulated_credits_program),
          trailing: Text(_program.accumulatedCredits),
        ),
        ListTile(
          title: Text(
              AppIntl.of(context).profile_number_registered_credits_program),
          trailing: Text(_program.registeredCredits),
        ),
        ListTile(
          title: Text(
              AppIntl.of(context).profile_number_completed_courses_program),
          trailing: Text(_program.completedCourses),
        ),
        ListTile(
          title:
              Text(AppIntl.of(context).profile_number_failed_courses_program),
          trailing: Text(_program.failedCourses),
        ),
        ListTile(
          title: Text(
              AppIntl.of(context).profile_number_equivalent_courses_program),
          trailing: Text(_program.equivalentCourses),
        ),
        ListTile(
          title: Text(AppIntl.of(context).profile_status_program),
          trailing: Text(_program.status),
        ),
      ],
    );
  }
}
