// widgets/GradeList.dart

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:notredame/features/student/grades/grades_viewmodel.dart';
import 'package:notredame/features/student/grades/widget-grade-view/grade_session_courses.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GradeList extends StatelessWidget {
  final GradesViewModel model;

  const GradeList({required this.model});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: AnimationLimiter(
        child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: model.coursesBySession.length,
            itemBuilder: (BuildContext context, int index) =>
                AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 750),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: GradeSessionCourses(
                        index: index,
                        sessionName: _sessionName(
                            model.sessionOrder[index], AppIntl.of(context)!),
                        courses:
                            model.coursesBySession[model.sessionOrder[index]]!,
                        sessionOrder: model.sessionOrder,
                      ),
                    ),
                  ),
                )),
      ),
    );
  }

  /// Build the complete name of the session for the user local.
  String _sessionName(String shortName, AppIntl intl) {
    switch (shortName[0]) {
      case 'H':
        return "${intl.session_winter} ${shortName.substring(1)}";
      case 'A':
        return "${intl.session_fall} ${shortName.substring(1)}";
      case 'É':
        return "${intl.session_summer} ${shortName.substring(1)}";
      default:
        return intl.session_without;
    }
  }
}
