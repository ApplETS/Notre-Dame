import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';

import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/features/app/widgets/dismissible_card.dart';
import 'package:notredame/features/dashboard/widgets/grades_card/grades_card.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/features/student/grades/widgets/grade_button.dart';

import '../../../../common/helpers.dart';
import '../../../app/repository/mocks/course_repository_mock.dart';
import 'grades_card_models.dart';

void main() {
  late CourseRepositoryMock courseRepository;
  late NavigationService navigationService;
  late AppIntl intl;
  late GradesCardModels models;

  setUp(() async {
    courseRepository = setupCourseRepositoryMock();
    navigationService = setupNavigationServiceMock();
    intl = await setupAppIntl();
    setupSettingsManagerMock();

    models = GradesCardModels();
  });

  tearDown(() {
    unregister<CourseRepository>();
    unregister<NavigationService>();
    unregister<SettingsManager>();
  });

  group('UI - gradesCard', () {
    testWidgets('Has card grades displayed - with no courses',
            (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(
          child: GradesCard(onDismissed: () {}, key: UniqueKey())));
      await tester.pumpAndSettle();

      // Find grades card
      final gradesCard =
      find.widgetWithText(DismissibleCard, intl.grades_title);
      expect(gradesCard, findsOneWidget);

      // Find empty grades card
      final gradesEmptyTitle = find.text(
          intl.grades_msg_no_grades.split("\n").first);
      expect(gradesEmptyTitle, findsOneWidget);
    });

    testWidgets('Has card grades displayed - with courses',
            (WidgetTester tester) async {
      CourseRepositoryMock.stubCourses(courseRepository,
          toReturn: models.courses);
      CourseRepositoryMock.stubGetCourses(courseRepository,
          toReturn: models.courses);
      CourseRepositoryMock.stubActiveSessions(courseRepository, toReturn: [
        models.session
      ]);

      await tester.pumpWidget(localizedWidget(
          child: GradesCard(onDismissed: () {}, key: UniqueKey())));
      await tester.pumpAndSettle();

      // Find grades card
      final gradesCard =
      find.widgetWithText(DismissibleCard, intl.grades_title);
      expect(gradesCard, findsOneWidget);

      // Find grades buttons in the card
      final gradesButtons = find.byType(GradeButton);
      expect(gradesButtons, findsNWidgets(2));
    });

    testWidgets('gradesCard is dismissible',
            (WidgetTester tester) async {
      var isDismissed = false;

      await tester.pumpWidget(localizedWidget(
          child: GradesCard(onDismissed: () => isDismissed = true, key: UniqueKey())));
      await tester.pumpAndSettle();

      // Find Dismissible Cards
      expect(find.byType(Dismissible), findsOneWidget);
      expect(find.text(intl.grades_title, skipOffstage: false),
          findsOneWidget);

      // Swipe Dismissible grades Card horizontally
      final finder = find.widgetWithText(Dismissible, intl.grades_title);
      await tester.drag(finder, const Offset(1000.0, 0.0));
      await tester.pumpAndSettle();

      // Check that the card is now absent from the view
      expect(isDismissed, true);
    });

    testWidgets("gradesCard reacts to click",
            (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(
          child: GradesCard(onDismissed: () {}, key: UniqueKey())));
      await tester.pumpAndSettle();

      // Swipe Dismissible progress Card horizontally
      final card = find.text(intl.grades_title);

      await tester.tap(card);
      await tester.pumpAndSettle();

      verify(navigationService.pushNamedAndRemoveUntil(RouterPaths.student)).called(1);
    });
  });
}
