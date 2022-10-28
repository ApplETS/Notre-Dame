// FLUTTER / DART / THIRD-PARTIES
import 'dart:io';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// MANAGER
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';

// SERVICES
import 'package:notredame/core/services/networking_service.dart';
import '../../mock/services/analytics_service_mock.dart';

// VIEWS
import 'package:notredame/ui/views/student_view.dart';

//WIDGETS
import 'package:notredame/ui/widgets/base_scaffold.dart';

// HELPER
import '../../helpers.dart';

// MOCKS
import '../../mock/managers/course_repository_mock.dart';

void main() {
  CourseRepository courseRepository;

  group('StudentView - ', () {
    setUp(() async {
      setupNavigationServiceMock();
      setupNetworkingServiceMock();
      courseRepository = setupCourseRepositoryMock();
      setupSettingsManagerMock();
      setupAnalyticsServiceMock();

      CourseRepositoryMock.stubCourses(
          courseRepository as CourseRepositoryMock);
      CourseRepositoryMock.stubGetCourses(
          courseRepository as CourseRepositoryMock,
          fromCacheOnly: false);
      CourseRepositoryMock.stubGetCourses(
          courseRepository as CourseRepositoryMock,
          fromCacheOnly: true);
    });

    tearDown(() {
      unregister<CourseRepository>();
      unregister<NetworkingService>();
      unregister<SettingsManager>();
      unregister<AnalyticsServiceMock>();
    });

    group('UI - ', () {
      testWidgets('has Tab bar and sliverAppBar and BaseScaffold',
          (WidgetTester tester) async {
        await tester.pumpWidget(
            localizedWidget(child: FeatureDiscovery(child: StudentView())));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(find.byType(TabBar), findsOneWidget);

        expect(find.byType(SliverAppBar), findsOneWidget);

        expect(find.byType(BaseScaffold), findsOneWidget);
      });

      group("golden - ", () {
        testWidgets("default view (no events)", (WidgetTester tester) async {
          tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

          await tester.pumpWidget(
              localizedWidget(child: FeatureDiscovery(child: StudentView())));
          await tester.pumpAndSettle(const Duration(seconds: 1));

          await expectLater(find.byType(StudentView),
              matchesGoldenFile(goldenFilePath("studentView_1")));
        });
      }, skip: !Platform.isLinux);
    });
  });
}
