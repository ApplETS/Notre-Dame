// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/features/app/integration/networking_service.dart';
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/features/app/widgets/base_scaffold.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/features/student/student_view.dart';
import '../../common/helpers.dart';
import '../app/analytics/mocks/analytics_service_mock.dart';
import '../app/repository/mocks/course_repository_mock.dart';

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
        await tester.pumpWidget(localizedWidget(child: StudentView()));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(find.byType(TabBar), findsOneWidget);

        expect(find.byType(SliverAppBar), findsOneWidget);

        expect(find.byType(BaseScaffold), findsOneWidget);
      });
    });
  });
}
