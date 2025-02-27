import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/core/ui/dismissible_card.dart';
import 'package:notredame/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:notredame/ui/student/grades/widgets/grade_button.dart';
import 'package:skeletonizer/skeletonizer.dart';

class GradesCard extends StatelessWidget {
  final NavigationService _navigationService = locator<NavigationService>();
  
  final DashboardViewModel _model;
  final VoidCallback _onDismissed;

  GradesCard({super.key, required DashboardViewModel model, required VoidCallback onDismissed})
    : _model = model, _onDismissed = onDismissed;

  @override
  Widget build(BuildContext context) {
    final bool loaded = !_model.busy(_model.courses);
    late List<Course> courses = _model.courses;

    // When loading courses, there are 2 stages. First, the courses of user are fetched, then, grades are fetched.
    // During that first stage, putting empty courses with no title allows for a smoother transition.
    if (courses.isEmpty && !loaded) {
      final Course skeletonCourse = Course(
          acronym: " ",
          title: "",
          group: "",
          session: "",
          programCode: "",
          numberOfCredits: 0);
      courses = [
        skeletonCourse,
        skeletonCourse,
        skeletonCourse,
        skeletonCourse
      ];
    }

    return DismissibleCard(
      key: UniqueKey(),
      onDismissed: (DismissDirection direction) => _onDismissed(),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.fromLTRB(17, 15, 0, 0),
                child: GestureDetector(
                  onTap: () => _navigationService
                      .pushNamedAndRemoveUntil(RouterPaths.student),
                  child: Text(AppIntl.of(context)!.grades_title,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              ),
            ),
            if (_model.courses.isEmpty && loaded)
              SizedBox(
                height: 100,
                child: Center(
                    child: Text(AppIntl.of(context)!
                        .grades_msg_no_grades
                        .split("\n")
                        .first)),
              )
            else
              Skeletonizer(
                enabled: !loaded,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(17, 10, 15, 10),
                  child: Wrap(
                    children: courses
                        .map((course) => GradeButton(course,
                            color: context.theme.appColors.backgroundAlt))
                        .toList(),
                  ),
                ),
              )
          ]),
    );
  }
}