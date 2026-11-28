// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/dashboard/view_model/cards/schedule_card_viewmodel.dart';
import 'package:notredame/ui/dashboard/widgets/cards/schedule_card.dart';
import 'package:notredame/ui/schedule/schedule_controller.dart';
import 'package:notredame/ui/schedule/widgets/calendars/day_calendar.dart';
import '../../../../helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppIntl intl;

  setUp(() async {
    intl = await setupAppIntl();
    setupCourseRepositoryMock();
    setupSettingsRepositoryMock();
    setupScheduleServiceMock();
  });

  group('ScheduleCard', () {
    testWidgets('renders base title', (tester) async {
      await tester.pumpWidget(
        localizedWidget(
          child: ScheduleCard(model: ScheduleCardViewmodel(intl: intl)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ScheduleCard), findsOneWidget);
      expect(find.byType(DayCalendar), findsOneWidget);
    });

    testWidgets('passes correct parameters to DayCalendar', (tester) async {
      await tester.pumpWidget(
        localizedWidget(
          child: ScheduleCard(model: ScheduleCardViewmodel(intl: intl)),
        ),
      );

      await tester.pumpAndSettle();

      final dayCalendar = tester.widget<DayCalendar>(find.byType(DayCalendar));

      expect(dayCalendar.listView, false);
      expect(dayCalendar.controller, isA<ScheduleController>());
      expect(dayCalendar.selectedDate, isNotNull);
    });
  });
}
