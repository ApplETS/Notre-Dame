// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:rive/rive.dart';

// Project imports:
import 'package:notredame/features/app/error/not_found/not_found_view.dart';
import '../../helpers.dart';
import '../../mock/services/rive_animation_service_mock.dart';

void main() {
  group('NotFoundView - ', () {
    const String pageNotFoundPassed = "/test";
    setUp(() async {
      setupNavigationServiceMock();
      setupAnalyticsServiceMock();
      final riveAnimationMock = setupRiveAnimationServiceMock();
      RiveAnimationServiceMock.stubLoadRiveFile(
          riveAnimationMock, 'dot_jumping', RuntimeArtboard());
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets('has a go back to dashboard button',
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(
            child: const NotFoundView(pageName: pageNotFoundPassed)));
        await tester.pumpAndSettle();

        expect(find.byType(ElevatedButton), findsOneWidget);
        // Make sure to find one text for the title,one for the description and
        // one for the button text
        expect(find.byType(Text), findsNWidgets(3));
        // Make sure to find the page name somewhere
        expect(find.textContaining(pageNotFoundPassed), findsOneWidget);
      });
      group("golden - ", () {
        testWidgets("default view (no events)", (WidgetTester tester) async {
          tester.view.physicalSize = const Size(800, 1410);

          await tester.pumpWidget(localizedWidget(
              child: const NotFoundView(pageName: pageNotFoundPassed)));
          await tester.pumpAndSettle();

          await expectLater(find.byType(NotFoundView),
              matchesGoldenFile(goldenFilePath("notFoundView_1")));
        });
      }, skip: !Platform.isLinux);
    });
  });
}
