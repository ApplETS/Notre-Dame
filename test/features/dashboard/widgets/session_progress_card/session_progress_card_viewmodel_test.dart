// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/features/app/signets-api/models/session.dart';
import 'package:notredame/features/dashboard/progress_bar_text_options.dart';
import 'package:notredame/features/dashboard/widgets/session_progress_card/session_progress_card_viewmodel.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import '../../../../common/helpers.dart';
import '../../../app/repository/mocks/course_repository_mock.dart';
import '../../../more/settings/mocks/settings_manager_mock.dart';

void main() {
  late CourseRepositoryMock courseRepository;
  late SettingsManagerMock settingsManager;
  late AppIntl appIntl;

  late SessionProgressCardViewmodel viewmodel;

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
      deadlineCancellationASEQ: DateTime(2017, 1, 11, 1, 1));

  group("SessionProgressCardViewModel", () {
    setUp(() async {
      courseRepository = setupCourseRepositoryMock();
      settingsManager = setupSettingsManagerMock();
      appIntl = await setupAppIntl();

      viewmodel = SessionProgressCardViewmodel(appIntl);
    });

    tearDown(() {
      unregister<CourseRepository>();
      unregister<SettingsManager>();
    });

    group("futureToRun - ", () {
      test("There is an active session", () async {
        CourseRepositoryMock.stubActiveSessions(courseRepository,
            toReturn: [session]);
        SettingsManagerMock.stubDateTimeNow(settingsManager,
            toReturn: DateTime(2020));

        final progress = await viewmodel.futureToRun();

        expect(progress, 0.5);
        expect(viewmodel.progressBarText, "1 days elapsed / 2 days");
      });

      test("Invalid date (Superior limit)", () async {
        CourseRepositoryMock.stubActiveSessions(courseRepository,
            toReturn: [session]);
        SettingsManagerMock.stubDateTimeNow(settingsManager,
            toReturn: DateTime(2020, 1, 20));

        final progress = await viewmodel.futureToRun();

        expect(progress, 1);
        expect(viewmodel.progressBarText, "2 days elapsed / 2 days");
      });

      test("Invalid date (Lower limit)", () async {
        CourseRepositoryMock.stubActiveSessions(courseRepository,
            toReturn: [session]);
        SettingsManagerMock.stubDateTimeNow(settingsManager,
            toReturn: DateTime(2019, 12, 31));

        final progress = await viewmodel.futureToRun();

        expect(progress, 0);
        expect(viewmodel.progressBarText, "0 days elapsed / 2 days");
      });

      test("Active session is null", () async {
        CourseRepositoryMock.stubActiveSessions(courseRepository);

        final progress = await viewmodel.futureToRun();

        expect(progress, -1.0);
        expect(viewmodel.progressBarText, "0 days elapsed / 0 days");
      });
    });

    group("updateProgressBarTextSetting - ", () {
      test(
          "progressBarText flag should be set to percentage when called once",
              () async {
            CourseRepositoryMock.stubActiveSessions(courseRepository);

            viewmodel.updateProgressBarTextSetting();

            verify(settingsManager.setString(PreferencesFlag.progressBarText,
                ProgressBarText.values[1].toString()))
                .called(1);
            expect(viewmodel.progressBarText, "0 %");
          });

      test(
          "progressBarText flag should be set to remainingDays when called twice",
              () async {
            CourseRepositoryMock.stubActiveSessions(courseRepository);

            viewmodel.updateProgressBarTextSetting();
            viewmodel.updateProgressBarTextSetting();

            verify(settingsManager.setString(PreferencesFlag.progressBarText,
                ProgressBarText.values[2].toString()))
                .called(1);
            expect(viewmodel.progressBarText, "0 remaining days");
          });

      test(
          "progressBarText flag should be set to daysElapsedWithTotalDays when called three times",
              () async {
            CourseRepositoryMock.stubActiveSessions(courseRepository);

            viewmodel.updateProgressBarTextSetting();
            viewmodel.updateProgressBarTextSetting();
            viewmodel.updateProgressBarTextSetting();

            verify(settingsManager.setString(PreferencesFlag.progressBarText,
                ProgressBarText.values[0].toString()))
                .called(1);
            expect(viewmodel.progressBarText, "0 days elapsed / 0 days");
          });
    });
  });
}
