// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:rive/rive.dart';

// Project imports:
import 'package:notredame/features/app/error/not_found/not_found_view.dart';
import '../../../../common/helpers.dart';
import '../../presentation/mocks/rive_animation_service_mock.dart';

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
    });
  });
}
