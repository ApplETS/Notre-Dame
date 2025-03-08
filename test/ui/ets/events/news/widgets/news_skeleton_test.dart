// Package imports:
import 'package:flutter_test/flutter_test.dart';
// Project imports:
import 'package:notredame/ui/ets/events/news/widgets/news_card_skeleton.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../helpers.dart';

void main() {
  group('News card skeleton Tests', () {
    setUpAll(() async {
      await setupAppIntl();
    });

    testWidgets('Displays a news card skeleton', (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: NewsCardSkeleton()));

      expect(
        find.byWidgetPredicate(
          (widget) => widget is Skeletonizer,
        ),
        findsNWidgets(2),
      );
    });
  });
}
