// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/services/launch_url_service.dart';
import 'package:notredame/domain/constants/urls.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/student/grades/widgets/grade_not_available.dart';
import '../../../../data/mocks/services/launch_url_service_mock.dart';
import '../../../../helpers.dart';

void main() {
  late AppIntl intl;

  group("GradeNotAvailableTest -", () {
    setUp(() async {
      intl = await setupAppIntl();
      setupLaunchUrlServiceMock();
    });

    group("UI -", () {
      group("when isEvaluationPeriod is false -", () {
        testWidgets('shows school icon', (WidgetTester tester) async {
          await tester.pumpWidget(localizedWidget(child: GradeNotAvailable()));
          await tester.pumpAndSettle();

          expect(find.byIcon(Icons.school), findsOneWidget);
        });

        testWidgets('shows no-grade message with titleLarge style', (WidgetTester tester) async {
          await tester.pumpWidget(localizedWidget(child: GradeNotAvailable()));
          await tester.pumpAndSettle();

          final textWidget = tester.widget<Text>(find.text(intl.grades_msg_no_grade));
          expect(textWidget, isNotNull);
          expect(textWidget.style, Theme.of(tester.element(find.byType(GradeNotAvailable))).textTheme.titleLarge);
        });

        testWidgets('does not show complete-evaluations button', (WidgetTester tester) async {
          await tester.pumpWidget(localizedWidget(child: GradeNotAvailable()));
          await tester.pumpAndSettle();

          expect(find.byIcon(Icons.star), findsNothing);
          expect(find.text(intl.grades_complete_evaluations), findsNothing);
        });

        testWidgets('shows retry button with red background', (WidgetTester tester) async {
          await tester.pumpWidget(localizedWidget(child: GradeNotAvailable()));
          await tester.pumpAndSettle();

          expect(find.byIcon(Icons.refresh), findsOneWidget);
          expect(find.text(intl.retry), findsOneWidget);

          final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
          final style = elevatedButton.style!.backgroundColor!.resolve(<WidgetState>{});
          expect(style, AppPalette.etsLightRed);
        });

        testWidgets('calls onPressed when retry button is tapped', (WidgetTester tester) async {
          bool pressed = false;
          await tester.pumpWidget(localizedWidget(child: GradeNotAvailable(onPressed: () => pressed = true)));
          await tester.pumpAndSettle();

          await tester.tap(find.byIcon(Icons.refresh));
          await tester.pumpAndSettle();

          expect(pressed, isTrue);
        });
      });

      group("when isEvaluationPeriod is true -", () {
        testWidgets('shows school icon', (WidgetTester tester) async {
          await tester.pumpWidget(localizedWidget(child: GradeNotAvailable(isEvaluationPeriod: true)));
          await tester.pumpAndSettle();

          expect(find.byIcon(Icons.school), findsOneWidget);
        });

        testWidgets('shows evaluations-not-completed message with bodyLarge style', (WidgetTester tester) async {
          await tester.pumpWidget(localizedWidget(child: GradeNotAvailable(isEvaluationPeriod: true)));
          await tester.pumpAndSettle();

          final textWidget = tester.widget<Text>(find.text(intl.grades_error_course_evaluations_not_completed));
          expect(textWidget, isNotNull);
          expect(textWidget.style, Theme.of(tester.element(find.byType(GradeNotAvailable))).textTheme.bodyLarge);
        });

        testWidgets('shows complete-evaluations filled button with star icon', (WidgetTester tester) async {
          await tester.pumpWidget(localizedWidget(child: GradeNotAvailable(isEvaluationPeriod: true)));
          await tester.pumpAndSettle();

          expect(find.byIcon(Icons.star), findsOneWidget);
          expect(find.text(intl.grades_complete_evaluations), findsOneWidget);
        });

        testWidgets('shows retry button with default style', (WidgetTester tester) async {
          await tester.pumpWidget(localizedWidget(child: GradeNotAvailable(isEvaluationPeriod: true)));
          await tester.pumpAndSettle();

          expect(find.byIcon(Icons.refresh), findsOneWidget);
          expect(find.text(intl.retry), findsOneWidget);

          final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
          // style is null when isEvaluationPeriod is true
          expect(elevatedButton.style, isNull);
        });

        testWidgets('tapping complete-evaluations button launches course reviews URL', (WidgetTester tester) async {
          final launchUrlService = locator<LaunchUrlService>() as LaunchUrlServiceMock;

          await tester.pumpWidget(localizedWidget(child: GradeNotAvailable(isEvaluationPeriod: true)));
          await tester.pumpAndSettle();

          await tester.tap(find.byIcon(Icons.star));
          await tester.pumpAndSettle();

          verify(launchUrlService.launchInBrowser(Urls.courseReviews)).called(1);
        });

        testWidgets('calls onPressed when retry button is tapped', (WidgetTester tester) async {
          bool pressed = false;
          await tester.pumpWidget(
            localizedWidget(child: GradeNotAvailable(isEvaluationPeriod: true, onPressed: () => pressed = true)),
          );
          await tester.pumpAndSettle();

          await tester.tap(find.byIcon(Icons.refresh));
          await tester.pumpAndSettle();

          expect(pressed, isTrue);
        });
      });
    });
  });
}
