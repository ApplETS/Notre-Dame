// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:percent_indicator/percent_indicator.dart';

// SERVICE
import 'package:notredame/ui/widgets/grade_circular_progress.dart';

// HELPERS
import '../../helpers.dart';

void main() {
  AppIntl intl;

  group("GradeCircularProgress -", () {
    setUp(() async {
      intl = await setupAppIntl();
    });

    group("UI -", () {
      testWidgets('has two CircularPercentIndicator', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(
            child: const GradeCircularProgress(
          1.0,
          finalGrade: "B",
          studentGrade: 90.0,
          averageGrade: 85.0,
        )));
        await tester.pumpAndSettle();

        final circularPercentIndicator = find.byType(CircularPercentIndicator);
        expect(circularPercentIndicator, findsNWidgets(2));
      });

      testWidgets("display the final grade if it is not null", (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(
            child: const GradeCircularProgress(
          1.0,
          finalGrade: "B",
        )));
        await tester.pumpAndSettle();

        final label = find.text("B");
        expect(label, findsOneWidget);
      });

      testWidgets("display the student grade if there is no final grade", (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(
            child: const GradeCircularProgress(
          1.0,
          studentGrade: 90.0,
        )));
        await tester.pumpAndSettle();

        final label = find.text("90 %");
        expect(label, findsOneWidget);
      });

      testWidgets("display the student grade if there is no final grade", (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(
            child: const GradeCircularProgress(
          1.0,
          studentGrade: 90.5,
        )));
        await tester.pumpAndSettle();

        final label = find.text("91 %");
        expect(label, findsOneWidget);
      });

      testWidgets("display the student grade if there is no final grade", (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(
            child: const GradeCircularProgress(
          1.0,
          studentGrade: 0.0,
        )));
        await tester.pumpAndSettle();

        final label = find.text("0 %");
        expect(label, findsOneWidget);
      });

      testWidgets("display N/A when no grade is available", (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: const GradeCircularProgress(1.0)));
        await tester.pumpAndSettle();

        final label = find.text(intl.grades_not_available);
        expect(label, findsOneWidget);
      });
    });
  });
}
