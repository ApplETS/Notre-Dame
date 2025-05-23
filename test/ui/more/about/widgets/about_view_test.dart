// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/ui/more/about/widgets/about_view.dart';
import '../../../../helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AboutView - ', () {
    setUp(() async {
      setupLaunchUrlServiceMock();
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets('has 7 images and 2 texts and 1 row', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: AboutView()));
        await tester.pumpAndSettle();

        final image = find.byType(Image);
        expect(image, findsOneWidget);

        final iconButton = find.byType(IconButton);
        expect(iconButton, findsNWidgets(5));

        final text = find.byType(Text);
        expect(text, findsNWidgets(2));

        final row = find.byType(Row);
        expect(row, findsOneWidget);
      });
    });

    testWidgets('toggles easter egg when combination is performed', (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: AboutView()));
      await tester.pumpAndSettle();

      final finder = find.byType(Image);
      expect(finder, findsOneWidget);

      // Up: vertical fling upwards
      await tester.fling(finder, const Offset(0, -50), 1000);
      await tester.pump(const Duration(milliseconds: 100));
      // Right: horizontal fling to the right
      await tester.fling(finder, const Offset(50, 0), 1000);
      await tester.pump(const Duration(milliseconds: 100));
      // Down: vertical fling downwards
      await tester.fling(finder, const Offset(0, 50), 1000);
      await tester.pump(const Duration(milliseconds: 100));
      // Left: horizontal fling to the left
      await tester.fling(finder, const Offset(-50, 0), 1000);
      await tester.pump(const Duration(milliseconds: 100));

      // Tap to activate
      await tester.tap(finder);
      await tester.pumpAndSettle();

      // Total images should now be 2 (original logo + easter egg)
      final images = find.byType(Image);
      expect(images, findsNWidgets(2));
    });
  });
}
