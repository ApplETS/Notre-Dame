// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:notredame/features/app/widgets/need_help_notice_dialog.dart';
import '../../../common/helpers.dart';
import '../../more/settings/mocks/settings_manager_mock.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  group('NeedHelpNoticeDialog - ', () {
    late SettingsManagerMock settingsManagerMock;

    setUp(() async {
      setupLaunchUrlServiceMock();
      setupNetworkingServiceMock();

      settingsManagerMock = setupSettingsManagerMock();
    });

    tearDown(() {});

    testWidgets('tapping "Cancel" closes dialog', (WidgetTester tester) async {
      SettingsManagerMock.stubLocale(settingsManagerMock);

      NeedHelpNoticeDialog dialog =
          NeedHelpNoticeDialog(openMail: () {}, launchWebsite: () {});

      await tester.pumpWidget(localizedWidget(child: dialog));
      await tester.pumpAndSettle();

      final cancelButton = find.byIcon(Icons.cancel);
      expect(cancelButton, findsAny);

      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      final dialogFound = find.byType(dialog.runtimeType);
      expect(dialogFound, findsNothing);
    });
  });
}
