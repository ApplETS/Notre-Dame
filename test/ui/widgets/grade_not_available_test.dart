// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MODELS
import 'package:notredame/ui/widgets/grade_not_available.dart';

// HELPERS
import '../../helpers.dart';

void main() {
  AppIntl intl;

  group("GradeNotAvailableTest -", () {
    setUp(() async {
      intl = await setupAppIntl();
    });

    group("UI -", () {
      testWidgets('has one icon and one text', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: const GradeNotAvailable()));
        await tester.pumpAndSettle();

        final label = find.text(intl.grades_msg_no_grades);
        expect(label, findsOneWidget);

        final icon = find.byIcon(Icons.school);
        expect(icon, findsOneWidget);
      });
    });
  });
}
