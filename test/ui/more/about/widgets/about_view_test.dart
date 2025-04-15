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
  });
}
