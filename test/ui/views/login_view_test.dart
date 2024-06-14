// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/features/settings/settings_manager.dart';
import 'package:notredame/features/login/user_repository.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/launch_url_service.dart';
import 'package:notredame/features/navigation/navigation_service.dart';
import 'package:notredame/core/services/preferences_service.dart';
import 'package:notredame/core/services/remote_config_service.dart';
import 'package:notredame/features/login/login_view.dart';
import 'package:notredame/features/login/widgets/password_text_field.dart';
import '../../helpers.dart';

void main() {
  late AppIntl intl;

  group('LoginView - ', () {
    setUp(() async {
      intl = await setupAppIntl();
      setupUserRepositoryMock();
      setupNavigationServiceMock();
      setupSettingsManagerMock();
      setupFlutterSecureStorageMock();
      setupPreferencesServiceMock();
      setupLaunchUrlServiceMock();
      setupAnalyticsServiceMock();
      setupRemoteConfigServiceMock();
    });

    tearDown(() {
      unregister<UserRepository>();
      unregister<NavigationService>();
      unregister<SettingsManager>();
      unregister<PreferencesService>();
      unregister<LaunchUrlService>();
      unregister<AnalyticsService>();
      unregister<RemoteConfigService>();
    });

    group('UI - ', () {
      testWidgets('has universal code and password text field',
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: LoginView()));
        await tester.pumpAndSettle();

        expect(
            find.widgetWithText(TextFormField, intl.login_prompt_universal_code,
                skipOffstage: false),
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
    });
  });
}
