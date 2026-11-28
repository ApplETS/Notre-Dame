// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:notredame/locator.dart';
import 'package:notredame/ui/dashboard/widgets/dashboard_view.dart';
import 'package:notredame/ui/dashboard/widgets/layouts/dashboard_phone_landscape_layout.dart';
import 'package:notredame/ui/dashboard/widgets/layouts/dashboard_phone_portrait_layout.dart';
import 'package:notredame/ui/dashboard/widgets/layouts/dashboard_tablet_landscape_layout.dart';
import 'package:notredame/ui/dashboard/widgets/layouts/dashboard_tablet_portrait_layout.dart';
import '../../../helpers.dart';

void main() {
  group("DashboardView - ", () {
    setUp(() async {
      setupSettingsRepositoryMock();
      setupListSessionsRepositoryMock();
      setupCourseRepositoryMock();
      setupRemoteConfigServiceMock();
      setupBroadcastMessageRepositoryMock();
      setupDynamicMessagesServiceMock();
      setupAnalyticsServiceMock();
      setupNavigationServiceMock();
      setupScheduleServiceMock();
      setupQuickLinkRepositoryMock();
      setupNetworkingServiceMock();
      setupInAppReviewServiceMock();
    });

    tearDown(() {
      locator.reset();
    });

    final layouts = <String, (Size, Type)>{
      'phone portrait': (const Size(390, 844), DashboardPhonePortraitLayout),
      'phone landscape': (const Size(844, 390), DashboardPhoneLandscapeLayout),
      'tablet portrait': (const Size(820, 1180), DashboardTabletPortraitLayout),
      'tablet landscape': (const Size(1180, 820), DashboardTabletLandscapeLayout),
    };

    final allLayouts = layouts.values.map((layout) => layout.$2).toList();

    for (final MapEntry(key: name, value: (size, expectedLayout)) in layouts.entries) {
      testWidgets('applies $expectedLayout on $name', (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(localizedWidget(child: const DashboardView()));

        for (final layout in allLayouts) {
          expect(find.byType(layout), layout == expectedLayout ? findsOneWidget : findsNothing);
        }
      });
    }
  });
}
