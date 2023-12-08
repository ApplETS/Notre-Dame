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
import 'package:notredame/core/services/remote_config_service.dart';
import 'package:notredame/ui/views/student_view.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';
import '../../helpers.dart';
import '../../mock/managers/course_repository_mock.dart';
import '../../mock/services/analytics_service_mock.dart';
import '../../mock/services/remote_config_service_mock.dart';

void main() {
  CourseRepository courseRepository;
  RemoteConfigService remoteConfigService;

  group('StudentView - ', () {
    setUp(() async {
      setupNavigationServiceMock();
      setupNetworkingServiceMock();
      courseRepository = setupCourseRepositoryMock();
      remoteConfigService = setupRemoteConfigServiceMock();
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

      RemoteConfigServiceMock.stubGetGradesEnabled(
          remoteConfigService as RemoteConfigServiceMock);
      RemoteConfigServiceMock.stubGetBroadcastColor(
          remoteConfigService as RemoteConfigServiceMock);
      RemoteConfigServiceMock.stubGetBroadcastEn(
          remoteConfigService as RemoteConfigServiceMock);
      RemoteConfigServiceMock.stubGetBroadcastFr(
          remoteConfigService as RemoteConfigServiceMock);
      RemoteConfigServiceMock.stubGetBroadcastTitleEn(
          remoteConfigService as RemoteConfigServiceMock);
      RemoteConfigServiceMock.stubGetBroadcastTitleFr(
          remoteConfigService as RemoteConfigServiceMock);
      RemoteConfigServiceMock.stubGetBroadcastType(
          remoteConfigService as RemoteConfigServiceMock);
      RemoteConfigServiceMock.stubGetBroadcastUrl(
          remoteConfigService as RemoteConfigServiceMock);
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
