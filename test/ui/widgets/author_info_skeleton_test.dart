// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';

// Project imports:
import 'package:notredame/ui/widgets/author_info_skeleton.dart';
import '../../helpers.dart';

void main() {
  group('AuthorInfoSkeleton Tests', () {
    setUpAll(() async {
      await setupAppIntl();
    });

    testWidgets('Displays an author info skeleton',
        (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: AuthorInfoSkeleton()));

      // Verify that the widget contains shimmer effects for text and icon button
      expect(find.byType(Shimmer), findsWidgets);
    });
  });
}
