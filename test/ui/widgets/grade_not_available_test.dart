// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/ui/widgets/grade_not_available.dart';
import '../../helpers.dart';

void main() {
  late AppIntl intl;

  group("GradeNotAvailableTest -", () {
    setUp(() async {
      intl = await setupAppIntl();
    });

    group("UI -", () {
      testWidgets('has one icon and one text', (WidgetTester tester) async {
        await tester
            .pumpWidget(localizedWidget(child: const GradeNotAvailable()));
        await tester.pumpAndSettle();

        final label = find.text(intl.grades_msg_no_grades.split('\n')[0]);
        expect(label, findsOneWidget);

        final icon = find.byIcon(Icons.school);
        expect(icon, findsOneWidget);
      });
    });
  });
}
