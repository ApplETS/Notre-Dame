// Package imports:
import 'package:material_ui/material_ui.dart';
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
  /// Scroll direction of the grades. When [Axis.vertical], the card must have a bounded height.
  final Axis direction;

  const GradesCard({super.key, this.direction = Axis.horizontal});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<GradesCardViewmodel>.reactive(
      viewModelBuilder: () => GradesCardViewmodel(intl: AppIntl.of(context)!),
      builder: (context, model, child) {
        List<Course> displayedCourses = List.from(model.courses);

        // When loading courses, there are 2 stages. First, the courses of user are fetched, then, grades are fetched.
        // During that first stage, putting empty courses with no title allows for a smoother transition.
        if (displayedCourses.isEmpty && model.busy(model.courses)) {
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

        final Widget content = (displayedCourses.isEmpty && !model.busy(model.courses))
            ? _buildNoGradesContent(context)
            : _buildGradesButton(displayedCourses, context, loading: model.busy(model.courses), direction: direction);

        return TitledCard(
          title: AppIntl.of(context)!.grades_title,
          // In vertical mode, the scroll view must be constrained by the remaining height of the card's Column,
          // otherwise it takes the full height of its content and overflows.
          child: direction == Axis.vertical ? Flexible(child: content) : content,
        );
      },
    );
  }

  static Widget _buildGradesButton(
    List<Course> courses,
    BuildContext context, {
    bool loading = false,
    required Axis direction,
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
