// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';

// MODEL
import 'package:notredame/core/models/course_activity.dart';

// WIDGET
import 'package:notredame/ui/widgets/course_activity_tile.dart';

// HELPERS
import '../../helpers.dart';

final CourseActivity course = CourseActivity(
    courseGroup: 'GEN101-01',
    courseName: 'Libelle du cours',
    activityName: 'TP',
    activityDescription: 'Travaux pratiques',
    activityLocation: 'À distance',
    startDateTime: DateTime(2020, 9, 3, 18),
    endDateTime: DateTime(2020, 9, 3, 20));

void main() {
  group("CourseActivityTile - ", () {
    testWidgets(
        "display the short title, entire title, type of activity, hours and local of the course",
        (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(
          child: CourseActivityTile(course)));
      await tester.pumpAndSettle();

      expect(find.text(course.courseGroup), findsOneWidget);
      expect(find.text("${course.courseName}\n${course.activityDescription}"),
          findsOneWidget);
      expect(find.text(course.activityLocation), findsOneWidget);

      expect(find.text("18:00"), findsOneWidget);
      expect(find.text("20:00"), findsOneWidget);
    });
  });
}
