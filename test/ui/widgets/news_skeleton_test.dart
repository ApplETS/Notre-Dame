// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';

// Project imports:
import 'package:notredame/features/ets/events/news/widgets/news_card_skeleton.dart';
import '../../helpers.dart';

void main() {
  group('News card skeleton Tests', () {
    setUpAll(() async {
      await setupAppIntl();
    });

    testWidgets('Displays a news card skeleton', (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: NewsCardSkeleton()));

      expect(find.byType(Shimmer), findsNWidgets(2));
    });
  });
}
