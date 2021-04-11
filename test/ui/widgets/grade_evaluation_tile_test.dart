// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// SERVICE
import 'package:notredame/core/services/navigation_service.dart';

// HELPERS
import '../../helpers.dart';

void main() {
  AppIntl intl;

  group("GradeEvaluationTile -", () {
    setUp(() async {
      intl = await setupAppIntl();
    });

    tearDown(() {
      unregister<NavigationService>();
    });

    group("UI -", () {
      testWidgets("display a circular progress bar, 2 texts and an icon", (WidgetTester tester) async {});

      testWidgets("dropdown display 6 lines of text", (WidgetTester tester) async {});

      testWidgets("dropdown display the right informations", (WidgetTester tester) async {});
    });
  });
}
