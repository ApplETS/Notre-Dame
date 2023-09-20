// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';

// MANAGERS / SERVICES
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/launch_url_service.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/services/preferences_service.dart';

// MOCKS
import '../../mock/services/analytics_service_mock.dart';
import '../../mock/services/launch_url_service_mock.dart';

// VIEWS
import 'package:notredame/ui/views/login_view.dart';
import 'package:notredame/ui/widgets/password_text_field.dart';

// HELPERS
import '../../helpers.dart';

void main() {
  AppIntl intl;
  LaunchUrlServiceMock launchUrlService;
  AnalyticsServiceMock analyticsService;

  group('LoginView - ', () {
    setUp(() async {
      intl = await setupAppIntl();
      setupUserRepositoryMock();
      setupNavigationServiceMock();
      setupSettingsManagerMock();
      setupPreferencesServiceMock();
      launchUrlService = setupLaunchUrlServiceMock() as LaunchUrlServiceMock;
      analyticsService = setupAnalyticsServiceMock() as AnalyticsServiceMock;
    });

    tearDown(() {
      unregister<UserRepository>();
      unregister<NavigationService>();
      unregister<SettingsManager>();
      unregister<PreferencesService>();
      unregister<LaunchUrlService>();
      unregister<AnalyticsService>();
    });

    group('UI - ', () {
      testWidgets('has universal code and password text field',
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: LoginView()));
        await tester.pumpAndSettle();

        expect(
            find.widgetWithText(
                TextFormField, intl.login_prompt_universal_code),
            findsOneWidget);
        expect(
            find.widgetWithText(PasswordFormField, intl.login_prompt_password),
            findsOneWidget);

        final Finder signInButton =
            find.widgetWithText(ElevatedButton, intl.login_action_sign_in);
        expect(signInButton, findsOneWidget);
        expect(
            tester.widget(signInButton),
            isA<ElevatedButton>()
                .having((source) => source.onPressed, 'onPressed', isNull));
      });

      testWidgets('should open emails', (WidgetTester tester) async {
        const url = 'mailto:applets@ens.etsmtl.ca?subject=ÉTSMobile Problem';
        LaunchUrlServiceMock.stubCanLaunchUrl(launchUrlService, url);
        LaunchUrlServiceMock.stubLaunchUrl(launchUrlService, url);

        await tester.pumpWidget(localizedWidget(child: LoginView()));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(InkWell, intl.need_help));

        // Rebuild the widget after the state has changed.
        await tester.pump();

        verify(launchUrlService.canLaunch(url)).called(1);
        verify(launchUrlService.launch(url)).called(1);
        verifyNoMoreInteractions(launchUrlService);
      });

      testWidgets('cannot launch email on this platform',
          (WidgetTester tester) async {
        const url = 'mailto:applets@ens.etsmtl.ca?subject=ÉTSMobile Problem';
        LaunchUrlServiceMock.stubCanLaunchUrl(launchUrlService, url,
            toReturn: false);
        LaunchUrlServiceMock.stubLaunchUrl(launchUrlService, url,
            toReturn: false);

        await tester.pumpWidget(localizedWidget(child: LoginView()));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(InkWell, intl.need_help));

        // Rebuild the widget after the state has changed.
        await tester.pumpAndSettle();

        verify(launchUrlService.canLaunch(url)).called(1);
        verifyNever(launchUrlService.launch(url));
        verifyNoMoreInteractions(launchUrlService);

        verify(analyticsService.logError(any, any)).called(1);
        verifyNoMoreInteractions(analyticsService);
      });
    });
  });
}
