// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:skeletonizer/skeletonizer.dart';

// Project imports:
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/core/ui/dismissible_card.dart';
import 'package:notredame/ui/student/grades/widgets/grade_button.dart';

class GradesCard extends StatelessWidget {
  final NavigationService _navigationService = locator<NavigationService>();

  final List<Course> courses;
  final VoidCallback onDismissed;
  final bool loading;

  GradesCard(
      {super.key,
      required this.courses,
      required this.onDismissed,
      required this.loading});

  @override
  Widget build(BuildContext context) {
    late List<Course> displayedCourses = courses;

    // When loading courses, there are 2 stages. First, the courses of user are fetched, then, grades are fetched.
    // During that first stage, putting empty courses with no title allows for a smoother transition.
    if (displayedCourses.isEmpty && loading) {
      final Course skeletonCourse = Course(
          acronym: " ",
          title: "",
          group: "",
          session: "",
          programCode: "",
          numberOfCredits: 0);
      displayedCourses = [
        skeletonCourse,
        skeletonCourse,
        skeletonCourse,
        skeletonCourse
      ];
    }

    return DismissibleCard(
      key: UniqueKey(),
      onDismissed: (DismissDirection direction) => onDismissed(),
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
            if (courses.isEmpty && !loading)
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
                enabled: loading,
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
