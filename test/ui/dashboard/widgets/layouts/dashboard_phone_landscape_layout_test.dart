// Package imports:
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/locator.dart';
import 'package:notredame/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:notredame/ui/dashboard/widgets/cards/grades_card.dart';
import 'package:notredame/ui/dashboard/widgets/cards/progress_bar_card.dart';
import 'package:notredame/ui/dashboard/widgets/cards/quick_links_card.dart';
import 'package:notredame/ui/dashboard/widgets/cards/schedule_card.dart';
import 'package:notredame/ui/dashboard/widgets/cards/session_reminder_card.dart';
import 'package:notredame/ui/dashboard/widgets/layouts/dashboard_phone_landscape_layout.dart';
import '../../../../helpers.dart';

void main() {
  late DashboardViewModel model;

  group("DashboardPhoneHorizontalLayout - ", () {
    setUp(() async {
      final intl = await setupAppIntl();

      setupSettingsRepositoryMock();
      setupListSessionsRepositoryMock();
      setupCourseRepositoryMock();
      setupRemoteConfigServiceMock();
      setupBroadcastMessageRepositoryMock();
      setupDynamicMessagesServiceMock();
      setupAnalyticsServiceMock();
      setupNavigationServiceMock();
      setupScheduleServiceMock();

      DashboardViewModel.hasAnimationPlayed = true;
      model = DashboardViewModel(intl: intl)..init(const TestVSync());
    });

    tearDown(() {
      model.dispose();
      locator.reset();
    });

    testWidgets('displays the right cards', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(844, 390);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        localizedWidget(
          child: DashboardPhoneHorizontalLayout(model: model, viewportHeight: tester.view.physicalSize.height),
        ),
      );

      expect(find.byType(SessionReminderCard, skipOffstage: false), findsOneWidget);
      expect(find.byType(ProgressBarCard, skipOffstage: false), findsOneWidget);
      expect(find.byType(ScheduleCard, skipOffstage: false), findsOneWidget);
      expect(find.byType(GradesCard, skipOffstage: false), findsOneWidget);
      expect(find.byType(QuickLinksCard, skipOffstage: false), findsNothing);
    });
  });
}
