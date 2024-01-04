// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:home_widget/home_widget.dart';

// Project imports:
import 'package:notredame/core/constants/widget_helper.dart';
import 'package:notredame/core/models/widget_models.dart';
import 'package:notredame/core/services/app_widget_service.dart';
import '../helpers.dart';
import '../mock/services/home_widget_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppWidgetService service;
  late HomeWidgetMock homeWidgetMock;

  group("AppWidgetServiceTest - ", () {
    setUp(() {
      setupAnalyticsServiceMock();
      service = AppWidgetService();
      homeWidgetMock = HomeWidgetMock();
    });

    test("init", () async {
      homeWidgetMock.stubInit();
      expect(await service.init(), true);
    });

    group("Progress Widget", () {
      const String title = "Widget title";
      const double progress = 0.5;
      const int elapsedDays = 10;
      const int totalDays = 20;
      const String suffix = "d";

      test("sendProgressData is successful", () async {
        final ProgressWidgetData progressWidgetData = ProgressWidgetData(
            title: title,
            progress: progress,
            elapsedDays: elapsedDays,
            totalDays: totalDays,
            suffix: suffix);

        // stub HomeWidget saveData behavior to match given input
        final listIds = [
          '${ProgressWidgetData.keyPrefix}progress',
          '${ProgressWidgetData.keyPrefix}elapsedDays',
          '${ProgressWidgetData.keyPrefix}totalDays',
          '${ProgressWidgetData.keyPrefix}suffix',
          '${ProgressWidgetData.keyPrefix}title'
        ];
        final listDatas = [progress, elapsedDays, totalDays, suffix, title];
        homeWidgetMock.stubSaveWidgetDataMock(listIds, listDatas);

        final test = await service.sendProgressData(progressWidgetData);
        expect(test, true);
      });

      test("sendProgressData stopped on error", () async {
        final ProgressWidgetData progressWidgetData = ProgressWidgetData(
            title: title,
            progress: progress,
            elapsedDays: elapsedDays,
            totalDays: totalDays,
            suffix: suffix);

        // stub HomeWidget saveData behavior to match given input
        final listIds = [
          '${ProgressWidgetData.keyPrefix}progress',
          '${ProgressWidgetData.keyPrefix}elapsedDays',
          '${ProgressWidgetData.keyPrefix}totalDays',
          '${ProgressWidgetData.keyPrefix}suffix',
          '${ProgressWidgetData.keyPrefix}title'
        ];
        final listDatas = [
          progress,
          elapsedDays,
          totalDays,
          suffix,
          "Expected title (different from the one actually sent)"
        ];
        homeWidgetMock.stubSaveWidgetDataMock(listIds, listDatas);

        expect(() async => service.sendProgressData(progressWidgetData),
            throwsException,
            reason: "Data is invalid for widget");
      });
    });

    group("Grades Widget", () {
      const List<String> courseAcronyms = ["ABC123", "DEF456", "GHI789"];
      const List<String> grades = ["A+", "B-", "N/A"];
      const String title = "Grades widget title";

      test("sendGradesData is successful", () async {
        final GradesWidgetData gradesWidgetData = GradesWidgetData(
            title: title, courseAcronyms: courseAcronyms, grades: grades);

        // stub HomeWidget saveData behavior to match given input
        final listIds = [
          '${GradesWidgetData.keyPrefix}courseAcronyms',
          '${GradesWidgetData.keyPrefix}grades',
          '${GradesWidgetData.keyPrefix}title'
        ];
        final listDatas = [courseAcronyms, grades, title];
        homeWidgetMock.stubSaveWidgetDataMock(listIds, listDatas);

        final test = await service.sendGradesData(gradesWidgetData);
        expect(test, true);
      });

      test("sendGradesData stopped on error", () async {
        final GradesWidgetData gradesWidgetData = GradesWidgetData(
            title: title, courseAcronyms: courseAcronyms, grades: grades);

        // stub HomeWidget saveData behavior to match given input
        final listIds = [
          '${GradesWidgetData.keyPrefix}courseAcronyms',
          '${GradesWidgetData.keyPrefix}grades',
          '${GradesWidgetData.keyPrefix}title'
        ];
        final listDatas = [courseAcronyms, grades, "Not the given title"];
        homeWidgetMock.stubSaveWidgetDataMock(listIds, listDatas);

        expect(() async => service.sendGradesData(gradesWidgetData),
            throwsException,
            reason: "Data is invalid for widget");
      });
    });

    group("updateWidget", () {
      test("progress", () async {
        const WidgetType type = WidgetType.progress;
        homeWidgetMock.stubUpdateWidgetMock(
            type.androidName, type.androidName, type.iOSname);
        expect(
            await HomeWidget.updateWidget(
                name: type.androidName,
                androidName: type.androidName,
                iOSName: type.iOSname),
            true);
      });

      test("grades", () async {
        const WidgetType type = WidgetType.grades;
        homeWidgetMock.stubUpdateWidgetMock(
            type.androidName, type.androidName, type.iOSname);
        expect(
            await HomeWidget.updateWidget(
                name: type.androidName,
                androidName: type.androidName,
                iOSName: type.iOSname),
            true);
      });
    });
  });
}
