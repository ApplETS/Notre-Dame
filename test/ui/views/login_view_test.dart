// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// GENERATED
import 'package:notredame/generated/l10n.dart';

// VIEWS
import 'package:notredame/ui/views/login_view.dart';
import 'package:notredame/ui/widgets/password_text_field.dart';

// HELPERS
import '../../helpers.dart';

void main() {
  AppIntl intl;

  group('LoginView - ', () {
    setUp(() async {
      intl = await setupAppIntl();
      setupUserRepositoryMock();
      setupNavigationServiceMock();
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets('has universal code and password text field', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: LoginView()));
        await tester.pumpAndSettle();

        expect(find.widgetWithText(TextFormField, intl.login_prompt_universal_code), findsOneWidget);
        expect(find.widgetWithText(PasswordFormField, intl.login_prompt_password), findsOneWidget);
        expect(find.widgetWithText(FlatButton, intl.login_action_sign_in), findsOneWidget);
      });
    });
  });

}