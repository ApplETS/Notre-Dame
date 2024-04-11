// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/services/networking_service.dart';
import 'package:notredame/ui/views/student_view.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';
import '../../helpers.dart';
import '../../mock/managers/course_repository_mock.dart';
import '../../mock/services/analytics_service_mock.dart';

void main() {
  CourseRepositoryMock courseRepositoryMock;

  group('StudentView - ', () {
    setUp(() async {
      setupNavigationServiceMock();
      setupNetworkingServiceMock();
      courseRepositoryMock = setupCourseRepositoryMock();
      setupSettingsManagerMock();
      setupAnalyticsServiceMock();

      CourseRepositoryMock.stubCourses(courseRepositoryMock);
      CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
      CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
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
          tester.view.physicalSize = const Size(800, 1410);

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
