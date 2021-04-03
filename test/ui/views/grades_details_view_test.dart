// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// MANAGER
import 'package:notredame/core/managers/course_repository.dart';

// MODELS
import 'package:notredame/core/models/course.dart';

// OTHERS
import '../../helpers.dart';

void main() {
  CourseRepository courseRepository;
  AppIntl intl;

  final Course course = Course(
      acronym: 'GEN101',
      group: '02',
      session: 'É2020',
      programCode: '999',
      grade: 'C+',
      numberOfCredits: 3,
      title: 'Cours générique');

  group("GradesDetailsView -", () {
    setUp(() async {
      intl = await setupAppIntl();
      courseRepository = setupCourseRepositoryMock();
    });
    tearDown(() {
      unregister<CourseRepository>();
    });

    group("UI -", () {
      testWidgets("Right message is displayed when there is no grades available", (WidgetTester tester) async {});
    });
  });
}
