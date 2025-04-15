// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/ui/core/ui/base_scaffold.dart';
import 'package:notredame/ui/student/widgets/student_view.dart';
import '../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../data/mocks/services/analytics_service_mock.dart';
import '../../../helpers.dart';

void main() {
  CourseRepositoryMock courseRepositoryMock;

  group('StudentView - ', () {
    setUp(() async {
      setupNavigationServiceMock();
      setupNetworkingServiceMock();
      courseRepositoryMock = setupCourseRepositoryMock();
      setupSettingsRepositoryMock();
      setupAnalyticsServiceMock();

      CourseRepositoryMock.stubCourses(courseRepositoryMock);
      CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
      CourseRepositoryMock.stubGetCourses(courseRepositoryMock, fromCacheOnly: true);
    });

    tearDown(() {
      unregister<CourseRepository>();
      unregister<NetworkingService>();
      unregister<SettingsRepository>();
      unregister<AnalyticsServiceMock>();
    });

    group('UI - ', () {
      testWidgets('has Tab bar and sliverAppBar and BaseScaffold', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: StudentView()));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(find.byType(TabBar), findsOneWidget);

        expect(find.byType(SliverAppBar), findsOneWidget);

        expect(find.byType(BaseScaffold), findsOneWidget);
      });
    });
  });
}
