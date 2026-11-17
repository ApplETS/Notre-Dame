// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/models/broadcast_message.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/launch_url_service.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/dashboard/widgets/broadcast_message_component.dart';
import '../../../data/mocks/services/analytics_service_mock.dart';
import '../../../data/mocks/services/launch_url_service_mock.dart';
import '../../../helpers.dart';

void main() {
  late LaunchUrlServiceMock launchUrlServiceMock;
  late AnalyticsServiceMock analyticsServiceMock;

  group('BroadcastMessageComponent -', () {
    setUp(() {
      launchUrlServiceMock = setupLaunchUrlServiceMock();
      analyticsServiceMock = setupAnalyticsServiceMock();
    });

    tearDown(() {
      locator.reset();
      unregister<LaunchUrlService>();
      unregister<AnalyticsService>();
    });

    testWidgets('displays message and link button is shows is URL is not empty', (WidgetTester tester) async {
      final messageWithUrl = BroadcastMessage(
        message: 'Veuillez faire une mise à jour',
        color: const Color(0x00000000),
        url: 'https://example.com',
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppIntl.localizationsDelegates,
          supportedLocales: AppIntl.supportedLocales,
          home: Scaffold(
            body: BroadcastMessageComponent(broadcastMessage: messageWithUrl, style: const TextStyle()),
          ),
        ),
      );

      expect(find.text('Veuillez faire une mise à jour'), findsOneWidget);

      expect(find.byIcon(Icons.open_in_new), findsOneWidget);

      await tester.tap(find.byIcon(Icons.open_in_new));
      verify(analyticsServiceMock.logEvent('BroadcastMessage', 'Hyperlink pressed')).called(1);
      verify(launchUrlServiceMock.launchInBrowser('https://example.com')).called(1);
    });

    testWidgets('link button is hidden if URL is empty', (WidgetTester tester) async {
      final messageWithoutUrl = BroadcastMessage(
        message: 'Veuillez faire une mise à jour',
        color: const Color(0x00000000),
        url: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BroadcastMessageComponent(broadcastMessage: messageWithoutUrl, style: const TextStyle()),
          ),
        ),
      );

      expect(find.byIcon(Icons.open_in_new), findsNothing);
    });
  });
}
