// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/repositories/list_sessions_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/dashboard/widgets/cards/progress_bar_card.dart';
import '../../../data/mocks/repositories/list_sessions_repository_mock.dart';
import '../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../data/mocks/services/analytics_service_mock.dart';
import '../../../helpers.dart';

void main() {
  late AppIntl intl;
  late AnalyticsServiceMock analyticsService;
  late SettingsRepositoryMock settingsRepository;
  late ListSessionsRepositoryMock listSessionRepository;

  group("ProgressBarCard - ", () {
    setUp(() async {
      intl = await setupAppIntl();

      analyticsService = AnalyticsServiceMock();
      settingsRepository = SettingsRepositoryMock();
      listSessionRepository = ListSessionsRepositoryMock();

      locator.registerSingleton<AnalyticsService>(analyticsService);
      locator.registerSingleton<SettingsRepository>(settingsRepository);
      locator.registerSingleton<ListSessionsRepository>(listSessionRepository);
    });
    tearDown(() {
      locator.reset();
    });

    testWidgets('Has card progressBar displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedWidget(
          child: ProgressBarCard(
            progressBarText: "45",
            progressBarAltText: "60",
            progress: 0.5,
            loading: false,
            showingPercentage: false,
            onToggle: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find progress card
      final progressCard = find.widgetWithText(Card, intl.progress_bar);
      expect(progressCard, findsOneWidget);

      // Find progress card linearProgressBar
      final linearProgressBarFinder = find.byType(CustomPaint);
      expect(linearProgressBarFinder, findsNWidgets(3));
    });

    testWidgets('Shows percentage text when showingPercentage is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedWidget(
          child: ProgressBarCard(
            progressBarText: "45",
            progressBarAltText: "60",
            progress: 0.5,
            loading: false,
            showingPercentage: true,
            onToggle: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("60"), findsOneWidget);
      expect(find.text("45"), findsNothing);
    });

    testWidgets('Shows days text when showingPercentage is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedWidget(
          child: ProgressBarCard(
            progressBarText: "45",
            progressBarAltText: "60",
            progress: 0.5,
            loading: false,
            showingPercentage: false,
            onToggle: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("45"), findsOneWidget);
      expect(find.text("60"), findsNothing);
    });

    testWidgets('calls onToggle when tapped', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        localizedWidget(
          child: ProgressBarCard(
            progressBarText: "45",
            progressBarAltText: "60",
            progress: 0.5,
            loading: false,
            showingPercentage: false,
            onToggle: () {
              tapped = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ProgressBarCard));

      expect(tapped, true);
    });
  });
}
