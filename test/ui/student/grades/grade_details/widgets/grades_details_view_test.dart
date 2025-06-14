// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/data/services/signets-api/models/course_evaluation.dart';
import 'package:notredame/data/services/signets-api/models/course_review.dart';
import 'package:notredame/data/services/signets-api/models/course_summary.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/student/grades/grade_details/widgets/grade_details_view.dart';
import '../../../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../../../helpers.dart';

void main() {
  late AppIntl intl;
  TestWidgetsFlutterBinding.ensureInitialized();

  SharedPreferences.setMockInitialValues({});
  late CourseRepositoryMock courseRepositoryMock;

  final CourseSummary courseSummary = CourseSummary(
    currentMark: 5,
    currentMarkInPercent: 50,
    markOutOf: 10,
    passMark: 6,
    standardDeviation: 2.3,
    median: 4.5,
    percentileRank: 99,
    evaluations: [
      CourseEvaluation(
        courseGroup: "02",
        title: "Laboratoire 1",
        weight: 10,
        teacherMessage: '',
        ignore: false,
        mark: 24,
        correctedEvaluationOutOf: "35",
        passMark: 25,
        standardDeviation: 2,
        median: 80,
        percentileRank: 5,
        published: true,
        targetDate: DateTime(2021, 01, 05),
      ),
    ],
  );

  final CourseSummary courseSummary2 = CourseSummary(
    currentMark: null,
    currentMarkInPercent: null,
    markOutOf: 100,
    passMark: 60,
    standardDeviation: 2.3,
    median: 4.5,
    percentileRank: 99,
    evaluations: [],
  );

  final completedCourseReview = CourseReview(
    acronym: 'GEN101',
    group: '02',
    teacherName: 'TEST',
    startAt: DateTime.now().subtract(const Duration(days: 1)),
    endAt: DateTime.now().add(const Duration(days: 1)),
    type: 'Cours',
    isCompleted: true,
  );

  final completedCourseReview2 = CourseReview(
    acronym: 'GEN102',
    group: '02',
    teacherName: 'TEST',
    startAt: DateTime.now().subtract(const Duration(days: 1)),
    endAt: DateTime.now().add(const Duration(days: 1)),
    type: 'Cours',
    isCompleted: true,
  );

  final nonCompletedCourseReview = CourseReview(
    acronym: 'GEN101',
    group: '02',
    teacherName: 'TEST',
    startAt: DateTime.now().subtract(const Duration(days: 1)),
    endAt: DateTime.now().add(const Duration(days: 1)),
    type: 'Cours',
    isCompleted: false,
  );

  final futureInactiveCourseReview = CourseReview(
    acronym: 'GEN101',
    group: '02',
    teacherName: 'TEST',
    startAt: DateTime.now().add(const Duration(days: 30)),
    endAt: DateTime.now().add(const Duration(days: 60)),
    type: 'Cours',
    isCompleted: false,
  );

  final completedReviewList = <CourseReview>[completedCourseReview, completedCourseReview2];
  final nonCompletedReviewList = <CourseReview>[nonCompletedCourseReview, futureInactiveCourseReview];
  final semiCompletedReviewList = <CourseReview>[completedCourseReview, futureInactiveCourseReview];

  final Course course = Course(
    acronym: 'GEN101',
    group: '02',
    session: 'H2020',
    programCode: '999',
    numberOfCredits: 3,
    title: 'Cours générique',
    summary: courseSummary,
    reviews: completedReviewList,
  );

  final Course course2 = Course(
    acronym: 'GEN102',
    group: '02',
    session: 'H2020',
    programCode: '999',
    numberOfCredits: 3,
    title: 'Cours générique',
    summary: courseSummary2,
    reviews: completedReviewList,
  );

  final Course courseWithoutSummary = Course(
    acronym: 'GEN101',
    group: '02',
    session: 'H2020',
    programCode: '999',
    numberOfCredits: 3,
    title: 'Cours générique',
  );

  final Course courseWithEvaluationSemiCompleted = Course(
    acronym: 'GEN101',
    group: '02',
    session: 'H2020',
    programCode: '999',
    numberOfCredits: 3,
    title: 'Cours générique',
    summary: courseSummary,
    reviews: semiCompletedReviewList,
  );

  final Course courseWithEvaluationNotCompleted = Course(
    acronym: 'GEN101',
    group: '02',
    session: 'H2020',
    programCode: '999',
    numberOfCredits: 3,
    title: 'Cours générique',
    summary: courseSummary,
    reviews: nonCompletedReviewList,
  );

  group('GradesDetailsView - ', () {
    setUp(() async {
      setupNavigationServiceMock();
      courseRepositoryMock = setupCourseRepositoryMock();
      setupSettingsRepositoryMock();
      setupNetworkingServiceMock();
      intl = await setupAppIntl();
    });

    tearDown(() {
      unregister<CourseRepository>();
      unregister<SettingsRepository>();
      unregister<NetworkingService>();
    });

    group('UI - ', () {
      testWidgets(
        'has a RefreshIndicator, GradeCircularProgress, three cards and evaluation tiles when a course is valid',
        (WidgetTester tester) async {
          setupFlutterToastMock(tester);
          CourseRepositoryMock.stubGetCourseSummary(courseRepositoryMock, course, toReturn: course);
          await tester
              .runAsync(() async {
                await tester.pumpWidget(localizedWidget(child: GradesDetailsView(course: course)));
                await tester.pumpAndSettle(const Duration(seconds: 2));
              })
              .then((value) {
                expect(find.byType(RefreshIndicator), findsOneWidget);

                // Find all the grade circular progress
                expect(find.byKey(const Key("GradeCircularProgress_summary")), findsOneWidget);
                for (final eval in courseSummary.evaluations) {
                  expect(find.byKey(Key("GradeCircularProgress_${eval.title}")), findsOneWidget);
                }

                expect(find.byType(Card), findsNWidgets(5));

                for (final eval in courseSummary.evaluations) {
                  expect(find.byKey(Key("GradeEvaluationTile_${eval.title}")), findsOneWidget);
                }
              });
        },
      );

      testWidgets(
        'when the page is at the top, it displays the course title, acronym, group, professor name and number of credits',
        (WidgetTester tester) async {
          setupFlutterToastMock(tester);
          CourseRepositoryMock.stubGetCourseSummary(courseRepositoryMock, courseWithoutSummary, toReturn: course);
          await tester
              .runAsync(() async {
                await tester.pumpWidget(localizedWidget(child: GradesDetailsView(course: courseWithoutSummary)));
                await tester.pumpAndSettle();
              })
              .then((value) {
                expect(find.byType(SliverAppBar), findsOneWidget);

                expect(find.text('Cours générique'), findsOneWidget);
                expect(find.text('GEN101'), findsOneWidget);
                expect(find.text('Group 02'), findsOneWidget);
                expect(find.text('Professor: TEST'), findsOneWidget);
                expect(find.text('Credits: 3'), findsOneWidget);
              });
        },
      );

      testWidgets(
        'when the page is at the top, it displays the course title, acronym, group, professor name and number of credits along with current grade and circular progress',
        (WidgetTester tester) async {
          setupFlutterToastMock(tester);
          CourseRepositoryMock.stubGetCourseSummary(courseRepositoryMock, course2, toReturn: course2);
          await tester
              .runAsync(() async {
                await tester.pumpWidget(localizedWidget(child: GradesDetailsView(course: course2)));
                await tester.pumpAndSettle();
              })
              .then((value) {
                expect(find.byType(SliverAppBar), findsOneWidget);

                expect(find.text(course2.title), findsOneWidget);
                expect(find.text(course2.acronym), findsOneWidget);
                expect(find.text('Group 02'), findsOneWidget);
                expect(find.text('Professor: TEST'), findsOneWidget);
                expect(find.text('Credits: 3'), findsOneWidget);

                final labelNa = find.text(intl.grades_not_available);
                // One for circular progress and one for the "Your grade" label
                expect(labelNa, findsAtLeastNWidgets(2));
              });
        },
      );

      testWidgets('when the page is scrolled at the bottom, it does not display the SliverToBoxAdapter', (
        WidgetTester tester,
      ) async {
        setupFlutterToastMock(tester);
        CourseRepositoryMock.stubGetCourseSummary(courseRepositoryMock, courseWithoutSummary, toReturn: course);

        await tester
            .runAsync(() async {
              await tester.pumpWidget(localizedWidget(child: GradesDetailsView(course: courseWithoutSummary)));
              await tester.pumpAndSettle();
            })
            .then((value) async {
              final gesture = await tester.startGesture(const Offset(0, 300)); //Position of the scrollview
              await gesture.moveBy(const Offset(0, -300)); //How much to scroll by
              await tester.pump();

              await tester.pump();

              expect(find.byType(SliverToBoxAdapter), findsNothing);
            });
      });

      testWidgets("display GradeNotAvailable when a course summary is null", (WidgetTester tester) async {
        setupFlutterToastMock(tester);
        CourseRepositoryMock.stubGetCourseSummary(
          courseRepositoryMock,
          courseWithoutSummary,
          toReturn: courseWithoutSummary,
        );

        await tester.pumpWidget(localizedWidget(child: GradesDetailsView(course: courseWithoutSummary)));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(find.byKey(const Key("GradeNotAvailable")), findsOneWidget);
      });

      testWidgets("display GradeNotAvailable when in the evaluation period and the evaluation isn't completed", (
        WidgetTester tester,
      ) async {
        setupFlutterToastMock(tester);
        CourseRepositoryMock.stubGetCourseSummary(
          courseRepositoryMock,
          courseWithEvaluationNotCompleted,
          toReturn: courseWithEvaluationNotCompleted,
        );

        await tester.pumpWidget(localizedWidget(child: GradesDetailsView(course: courseWithEvaluationNotCompleted)));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(find.byKey(const Key("EvaluationNotCompleted")), findsOneWidget);
      });

      testWidgets(
        'display regular course content (evaluations, circular progress, etc) when in the evaluation period and the evaluation is completed with a future (inactive) review not completed',
        (WidgetTester tester) async {
          setupFlutterToastMock(tester);
          CourseRepositoryMock.stubGetCourseSummary(
            courseRepositoryMock,
            courseWithEvaluationSemiCompleted,
            toReturn: courseWithEvaluationSemiCompleted,
          );
          await tester
              .runAsync(() async {
                await tester.pumpWidget(
                  localizedWidget(child: GradesDetailsView(course: courseWithEvaluationSemiCompleted)),
                );
                await tester.pumpAndSettle(const Duration(seconds: 2));
              })
              .then((value) {
                expect(find.byType(RefreshIndicator), findsOneWidget);

                // Find all the grade circular progress
                expect(find.byKey(const Key("GradeCircularProgress_summary")), findsOneWidget);
                for (final eval in courseSummary.evaluations) {
                  expect(find.byKey(Key("GradeCircularProgress_${eval.title}")), findsOneWidget);
                }

                expect(find.byType(Card), findsNWidgets(5));

                for (final eval in courseSummary.evaluations) {
                  expect(find.byKey(Key("GradeEvaluationTile_${eval.title}")), findsOneWidget);
                }
              });
        },
      );
    });
  });
}
