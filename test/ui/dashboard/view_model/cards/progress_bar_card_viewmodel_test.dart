// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/dashboard/view_model/dashboard_viewmodel.dart';
import '../../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../../data/mocks/repositories/list_sessions_repository_mock.dart';
import '../../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../../data/mocks/services/remote_config_service_mock.dart';
import '../../../../helpers.dart';

void main() {
  late SettingsRepositoryMock settingsManagerMock;
  late CourseRepositoryMock courseRepositoryMock;
  late RemoteConfigServiceMock remoteConfigServiceMock;
  late ListSessionsRepositoryMock listSessionsRepositoryMock;

  late DashboardViewModel viewModel;

  // Needed to support FlutterToast.
  TestWidgetsFlutterBinding.ensureInitialized();


  // Session
  final Session session = Session(
    shortName: "É2020",
    name: "Ete 2020",
    startDate: DateTime(2020).subtract(const Duration(days: 1)),
    endDate: DateTime(2020).add(const Duration(days: 1)),
    endDateCourses: DateTime(2022, 1, 10, 1, 1),
    startDateRegistration: DateTime(2017, 1, 9, 1, 1),
    deadlineRegistration: DateTime(2017, 1, 10, 1, 1),
    startDateCancellationWithRefund: DateTime(2017, 1, 10, 1, 1),
    deadlineCancellationWithRefund: DateTime(2017, 1, 11, 1, 1),
    deadlineCancellationWithRefundNewStudent: DateTime(2017, 1, 11, 1, 1),
    startDateCancellationWithoutRefundNewStudent: DateTime(2017, 1, 12, 1, 1),
    deadlineCancellationWithoutRefundNewStudent: DateTime(2017, 1, 12, 1, 1),
    deadlineCancellationASEQ: DateTime(2017, 1, 11, 1, 1),
  );

  group("DashboardViewModel - ", () {
    setUp(() async {
      // Setting up mocks
      courseRepositoryMock = setupCourseRepositoryMock();
      remoteConfigServiceMock = setupRemoteConfigServiceMock();
      settingsManagerMock = setupSettingsRepositoryMock();
      setupAnalyticsServiceMock();
      setupBroadcastMessageRepositoryMock();
      setupDynamicMessagesServiceMock();
      listSessionsRepositoryMock = setupListSessionsRepositoryMock();

      // Setup stubs for ListSessionsRepository
      ListSessionsRepositoryMock.stubGetStream(listSessionsRepositoryMock, stream: const Stream.empty());
      ListSessionsRepositoryMock.stubGetActiveSession(listSessionsRepositoryMock, session: null);

      viewModel = DashboardViewModel(intl: await setupAppIntl());
      CourseRepositoryMock.stubGetReplacedDays(courseRepositoryMock, fromCacheOnly: false);
      CourseRepositoryMock.stubGetReplacedDays(courseRepositoryMock, fromCacheOnly: true);
      CourseRepositoryMock.stubReplacedDays(courseRepositoryMock);
      CourseRepositoryMock.stubGetSessions(courseRepositoryMock, toReturn: [session]);
      CourseRepositoryMock.stubActiveSessions(courseRepositoryMock, toReturn: [session]);
      CourseRepositoryMock.stubUpcomingSessions(courseRepositoryMock);
      CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock);
      CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock, fromCacheOnly: true);
      CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
      SettingsRepositoryMock.stubDateTimeNow(settingsManagerMock, toReturn: DateTime(2020));

      RemoteConfigServiceMock.stubGetBroadcastEnabled(remoteConfigServiceMock);
      RemoteConfigServiceMock.stubGetBroadcastEn(remoteConfigServiceMock, toReturn: "");

    });

    tearDown(() {
      locator.reset();
      viewModel.dispose();
    });

    group("toggleProgressBarMode - ", () {
      test("should toggle showingPercentage and save preference to settings", () async {
        SettingsRepositoryMock.stubDashboardProgressBarPercentage(settingsManagerMock, toReturn: false);
        expect(viewModel.showingPercentage, false);

        // Toggle to true
        viewModel.progressBarModel.toggleProgressBarMode();
        expect(viewModel.showingPercentage, true);
        verify(settingsManagerMock.dashboard.displayProgressBarPercentage = true).called(1);

        // toggle again to false
        viewModel.progressBarModel.toggleProgressBarMode();
        expect(viewModel.showingPercentage, false);
        verify(settingsManagerMock.dashboard.displayProgressBarPercentage = false).called(1);
      });
    });

    group("progressBar refresh", () {
      test("should fetch new sessions with every refresh", () async {
        await viewModel.progressBarModel.futureToRun();

        verify(
          listSessionsRepositoryMock.getSessions(forceUpdate: true),
        ).called(1);
      });
    });

  });
}
