import 'package:flutter_test/flutter_test.dart';
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/features/dashboard/widgets/grades_card/grades_card_viewmodel.dart';

import '../../../../common/helpers.dart';
import '../../../app/repository/mocks/course_repository_mock.dart';
import 'grades_card_models.dart';

void main() {
  late CourseRepositoryMock courseRepository;
  late GradesCardViewModel viewModel;
  late GradesCardModels models;

  group('GradesCardViewModel - ', () {
    setUp(() {
      courseRepository = setupCourseRepositoryMock();

      viewModel = GradesCardViewModel();
      models = GradesCardModels();
    });

    tearDown(() {
      unregister<CourseRepository>();
    });

    group("futureToRun", () {
      test('first load from cache than call SignetsAPI to get the courses',
              () async {
            CourseRepositoryMock.stubSessions(courseRepository,
                toReturn: [models.session]);
            CourseRepositoryMock.stubGetSessions(courseRepository,
                toReturn: [models.session]);
            CourseRepositoryMock.stubActiveSessions(courseRepository,
                toReturn: [models.session]);

            CourseRepositoryMock.stubGetCourses(courseRepository,
                toReturn: models.courses);

            final data = await viewModel.futureToRun();

            expect(data, models.courses);
          });

      test('Signets throw an error while trying to get courses', () async {
        CourseRepositoryMock.stubSessions(courseRepository,
            toReturn: [models.session]);
        CourseRepositoryMock.stubGetSessions(courseRepository,
            toReturn: [models.session]);
        CourseRepositoryMock.stubActiveSessions(courseRepository,
            toReturn: [models.session]);

        CourseRepositoryMock.stubGetCoursesException(courseRepository);

        final data = await viewModel.futureToRun();

        expect(data, []);
      });

      test('Should return empty if there is no session active', () async {
        CourseRepositoryMock.stubSessions(courseRepository, toReturn: []);
        CourseRepositoryMock.stubActiveSessions(courseRepository,
            toReturn: []);

        final data = await viewModel.futureToRun();

        expect(data, []);
      });
    });

  });
}
