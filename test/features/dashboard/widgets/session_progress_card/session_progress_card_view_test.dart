// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/features/app/signets-api/models/session.dart';
import 'package:notredame/features/app/widgets/dismissible_card.dart';
import 'package:notredame/features/dashboard/widgets/session_progress_card/session_progress_card.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import '../../../../common/helpers.dart';
import '../../../app/repository/mocks/course_repository_mock.dart';
import '../../../more/settings/mocks/settings_manager_mock.dart';

void main() {
  late AppIntl intl;
  late SettingsManagerMock settingsManager;

  final Session session = Session(
      shortName: "É2020",
      name: "Ete 2020",
      startDate: DateTime(2020).subtract(const Duration(days: 1)),
      endDate: DateTime(2020).add(const Duration(days: 1)),
      endDateCourses: DateTime(2022, 1, 10, 1, 1),
      startDateRegistration: DateTime(2017, 1, 9, 1, 1),
      deadlineRegistration: DateTime(2017, 1, 10, 1, 1),
      startDateCancellationWithRefund: DateTime(2017, 1, 10, 1, 1),
      deadlineCancellationWithRefund: DateTime(2017, 1, 11, 1, 1),
      deadlineCancellationWithRefundNewStudent: DateTime(2017, 1, 11, 1, 1),
      startDateCancellationWithoutRefundNewStudent: DateTime(2017, 1, 12, 1, 1),
      deadlineCancellationWithoutRefundNewStudent: DateTime(2017, 1, 12, 1, 1),
      deadlineCancellationASEQ: DateTime(2017, 1, 11, 1, 1));

  group("UI - progressBar", () {
    setUp(() async {
      intl = await setupAppIntl();
      settingsManager = setupSettingsManagerMock();
      final courseRepositoryMock = setupCourseRepositoryMock();

      CourseRepositoryMock.stubGetSessions(courseRepositoryMock,
          toReturn: [session]);
      CourseRepositoryMock.stubActiveSessions(courseRepositoryMock,
          toReturn: [session]);
      SettingsManagerMock.stubDateTimeNow(settingsManager,
          toReturn: session.startDate);
    });

    tearDown(() {
      unregister<AppIntl>();
      unregister<CourseRepository>();
      unregister<SettingsManager>();
    });

    testWidgets('Has card progressBar displayed', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(
            child: SessionProgressCard(
                PreferencesFlag.progressBarCard,
                dismissCard: () => {},
                key: UniqueKey())));
        await tester.pumpAndSettle();

        // Find progress card Title
        final progressTitle = find.text(intl.progress_bar_title);
        expect(progressTitle, findsOneWidget);

        // Find progress card linearProgressBar
        final linearProgressBar = find.byType(LinearProgressIndicator);
        expect(linearProgressBar, findsOneWidget);
      });

    testWidgets('progressCard is dismissible',
            (WidgetTester tester) async {
          bool isDismissed = false;

          await tester.pumpWidget(localizedWidget(
              child: SessionProgressCard(
                  PreferencesFlag.progressBarCard,
                  dismissCard: () => isDismissed = true,
                  key: UniqueKey())));
          await tester.pumpAndSettle();

          // Swipe Dismissible progress Card horizontally
          final discardCard =
            find.widgetWithText(DismissibleCard, intl.progress_bar_title);
          await tester.ensureVisible(discardCard);
          await tester.drag(discardCard, const Offset(-1000.0, 0.0));
          await tester.pumpAndSettle();

          expect(isDismissed, true);
        });
  });
}
