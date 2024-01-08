// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/ui/widgets/password_text_field.dart';
import '../../helpers.dart';

void main() {
  late AppIntl intl;
  late PasswordFormField passwordFormField;

  group('PasswordFormField - ', () {
    setUpAll(() async {
      intl = await setupAppIntl();
      passwordFormField = PasswordFormField(
        validator: (value) {
          return null;
        },
        onEditionComplete: () {},
      );
    });

    testWidgets('has a label, the visibility icon and obscure text',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(localizedWidget(child: passwordFormField));
      await tester.pumpAndSettle();

      final icon = find.byIcon(Icons.visibility);
      final label = find.text(intl.login_prompt_password);

      expect(icon, findsOneWidget);
      expect(label, findsOneWidget);
    });

    group('visibility button', () {
      testWidgets(
          'toggling the visibility button should disable the obscureText property',
          (WidgetTester tester) async {
        await tester
            .pumpWidget(localizedWidget(child: passwordFormField));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.visibility));

        // Rebuild because the state changed
        await tester.pump();

        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
        expect(
            tester.widget(find.byType(TextField)),
            isA<TextField>().having(
                (source) => source.obscureText, 'obscureText', isFalse));
      });

      testWidgets(
          'toggling the visibility button two times should enable the obscureText property',
          (WidgetTester tester) async {
        await tester
            .pumpWidget(localizedWidget(child: passwordFormField));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.visibility));
        // Rebuild because the state changed
        await tester.pump();
        await tester.tap(find.byIcon(Icons.visibility_off));
        // Rebuild because the state changed
        await tester.pump();

        expect(find.byIcon(Icons.visibility), findsOneWidget);
        expect(
            tester.widget(find.byType(TextField)),
            isA<TextField>()
                .having((source) => source.obscureText, 'obscureText', isTrue));
      });
    });
  });
}
