// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/features/schedule/schedule_default/schedule_default.dart';
import '../../../common/helpers.dart';

void main() {
  late AppIntl intl;

  group('ScheduleDefault Tests', () {
    setUpAll(() async {
      intl = await setupAppIntl();
    });

    testWidgets('Displays no schedule message when there are no events',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          localizedWidget(child: const ScheduleDefault(calendarEvents: [])));
      await tester.pumpAndSettle();
      expect(find.text(intl.no_schedule_available), findsOneWidget);
    });
  });
}
