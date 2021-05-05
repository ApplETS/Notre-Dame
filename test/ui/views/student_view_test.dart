// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// MANAGER
import 'package:notredame/core/managers/course_repository.dart';

// VIEW
import 'package:notredame/ui/views/student_view.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';

import '../../helpers.dart';
import '../../mock/managers/course_repository_mock.dart';
import '../../mock/services/networking_service_mock.dart';

void main() {
  CourseRepository courseRepository;
  NetworkingServiceMock networkingService;

  group('StudentView - ', () {
    setUp(() async {
      setupNavigationServiceMock();
      networkingService = setupNetworkingServiceMock() as NetworkingServiceMock;
      courseRepository = setupCourseRepositoryMock();

      CourseRepositoryMock.stubCourses(
          courseRepository as CourseRepositoryMock);
      CourseRepositoryMock.stubGetCourses(
          courseRepository as CourseRepositoryMock,
          fromCacheOnly: false);
      CourseRepositoryMock.stubGetCourses(
          courseRepository as CourseRepositoryMock,
          fromCacheOnly: true);

      // Stub to simulate that the user has an active internet connection
      NetworkingServiceMock.stubHasConnectivity(networkingService);
    });

    tearDown(() {
      unregister<CourseRepository>();
      unregister<NetworkingServiceMock>();
    });

    group('UI - ', () {
      testWidgets('has Tab bar and sliverAppBar and BaseScaffold',
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: StudentView()));
        await tester.pumpAndSettle();

        expect(find.byType(TabBar), findsOneWidget);

        expect(find.byType(SliverAppBar), findsOneWidget);

        expect(find.byType(BaseScaffold), findsOneWidget);
      });

      group("golden - ", () {
        testWidgets("default view (no events)", (WidgetTester tester) async {
          tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

          await tester.pumpWidget(localizedWidget(child: StudentView()));
          await tester.pumpAndSettle();

          await expectLater(find.byType(StudentView),
              matchesGoldenFile(goldenFilePath("studentView_1")));
        });
      });
    });
  });
}
