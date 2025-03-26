// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:notredame/ui/core/ui/need_help_notice_dialog.dart';
import '../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../helpers.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  group('NeedHelpNoticeDialog - ', () {
    late SettingsRepositoryMock settingsManagerMock;

    setUp(() async {
      setupLaunchUrlServiceMock();
      setupNetworkingServiceMock();

      settingsManagerMock = setupSettingsManagerMock();
    });

    tearDown(() {});

    testWidgets('tapping "Cancel" closes dialog', (WidgetTester tester) async {
      SettingsRepositoryMock.stubLocale(settingsManagerMock);

      NeedHelpNoticeDialog dialog = NeedHelpNoticeDialog(openMail: () {}, launchWebsite: () {});

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
