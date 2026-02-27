// Flutter imports:
import 'package:flutter_svg/flutter_svg.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/more/map/map_view.dart';
import '../../../../helpers.dart';

void main() {
  group('MapView - ', () {
    late AppIntl appIntl;

    setUp(() async {
      appIntl = await setupAppIntl();
      setupNetworkingServiceMock();
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets('has map and legend', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: const MapView()));
        await tester.pumpAndSettle();

        // Map and icons of the legend
        expect(find.byType(SvgPicture), findsExactly(3));
      });
    });
  });
}
