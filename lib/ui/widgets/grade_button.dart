// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MODEL
import 'package:notredame/core/models/course.dart';

// VIEW
import 'package:notredame/ui/views/grade_details_view.dart';

// CONSTANT
import 'package:notredame/ui/utils/app_theme.dart';

class GradeButton extends StatelessWidget {
  final Course course;

  const GradeButton(this.course);

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
            onTap: () {
              onPressed(context);
            },
            child: SizedBox(
              height: 68,
              width: 68,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DecoratedBox(
                            decoration: const BoxDecoration(
                                color: AppTheme.etsLightRed,
                                borderRadius:
                                    BorderRadius.only(topLeft: Radius.circular(2.5), topRight: Radius.circular(2.5))),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(course.acronym,
                                    style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white)),
                              ),
                            )),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                        child: Text(gradeString(AppIntl.of(context)),
                            style: TextStyle(
                              fontSize: 22,
                              color: Theme.of(context).brightness == Brightness.light
                                  ? AppTheme.etsDarkGrey
                                  : AppTheme.etsLightGrey,
                            ))),
                  )
                ],
              ),
            )),
      );

  /// Build the grade string based on the available information. By default
  /// will return [grades_not_available].
  String gradeString(AppIntl intl) {
    if (course.grade == null && course.summary != null && course.summary.markOutOf > 0) {
      return intl.grades_grade_in_percentage(course.summary.currentMarkInPercent.round());
    } else if (course.grade != null) {
      return course.grade;
    }

    return intl.grades_not_available;
  }

  void onPressed(BuildContext context) =>
    Navigator.push(context, MaterialPageRoute(builder: (context) => GradesDetailsView(course: course)));
}
