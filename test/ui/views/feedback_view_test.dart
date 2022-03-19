// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// VIEW
import 'package:notredame/ui/views/feedback_view.dart';

import '../../helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('FeedbackView - ', () {
    setUp(() async {});

    tearDown(() {});

    group('UI - ', () {
      testWidgets('has a richText and an elevated button',
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: FeedbackView()));
        await tester.pumpAndSettle();

        final richText = find.byType(RichText);
        expect(richText, findsOneWidget);

        final elevatedButton = find.byType(ElevatedButton);
        expect(elevatedButton, findsOneWidget);

        final listView = find.byType(ListView);
        expect(listView, findsOneWidget);
      });

      group("golden - ", () {
        testWidgets("default view", (WidgetTester tester) async {
          tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

          await tester.runAsync(() async {
            await tester.pumpWidget(
                localizedWidget(useScaffold: false, child: FeedbackView()));
            final Element element = tester.element(find.byType(Hero));
            final Hero widget = element.widget as Hero;
            final Image image = widget.child as Image;
            await precacheImage(image.image, element);
            await tester.pumpAndSettle();
          });
          await tester.pumpAndSettle();
          await expectLater(find.byType(FeedbackView),
              matchesGoldenFile(goldenFilePath("feedbackView_1")));
        });
      });
    });
  });
}
