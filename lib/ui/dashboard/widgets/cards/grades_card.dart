// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/core/ui/titled_card.dart';
import 'package:notredame/ui/dashboard/view_model/cards/grades_card_viewmodel.dart';
import 'package:notredame/ui/student/grades/widgets/grade_button.dart';

class GradesCard extends StatelessWidget {
  final List<Course> courses;
  final bool loading;

  const GradesCard({super.key, required this.courses, required this.loading});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<GradesCardViewmodel>.reactive(
      viewModelBuilder: () => GradesCardViewmodel(intl: AppIntl.of(context)!),
      builder: (context, model, child) {
        List<Course> displayedCourses = List.from(model.courses);

        // When loading courses, there are 2 stages. First, the courses of user are fetched, then, grades are fetched.
        // During that first stage, putting empty courses with no title allows for a smoother transition.
        if (displayedCourses.isEmpty && loading) {
          final Course skeletonCourse = Course(
            acronym: " ",
            title: "",
            group: "",
            session: "",
            programCode: "",
            numberOfCredits: 0,
          );
          displayedCourses = [skeletonCourse, skeletonCourse, skeletonCourse, skeletonCourse];
        }

        return TitledCard(
          title: AppIntl.of(context)!.grades_title,
          child: (displayedCourses.isEmpty && !loading)
              ? _buildNoGradesContent(context)
              : _buildGradesButton(displayedCourses, context, loading: loading),
        );
      },
    );
  }

  static Widget _buildGradesButton(
    List<Course> courses,
    BuildContext context, {
    bool loading = false,
    Axis direction = Axis.horizontal,
  }) => Skeletonizer(
    enabled: loading,
    child: SingleChildScrollView(
      scrollDirection: direction,
      padding: const EdgeInsets.fromLTRB(17, 10, 15, 10),
      child: Flex(
        direction: direction,
        spacing: 10,
        children: courses.map((course) => GradeButton(course, color: context.theme.appColors.backgroundAlt)).toList(),
      ),
    ),
  );

  static SizedBox _buildNoGradesContent(BuildContext context) =>
      SizedBox(height: 100, child: Center(child: Text(AppIntl.of(context)!.grades_msg_no_grades.split("\n").first)));
}
