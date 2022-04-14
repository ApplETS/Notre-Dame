// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:home_widget/home_widget.dart';
import 'package:mockito/mockito.dart';

// CONSTANTS
import 'package:notredame/core/constants/widget_types.dart';
import 'package:notredame/core/services/analytics_service.dart';

// SERVICE
import 'package:notredame/core/services/app_widget_service.dart';

// MODEL
import 'package:notredame/core/models/widget_models.dart';

// OTHER
import '../helpers.dart';
import '../mock/services/home_widget_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  AppWidgetService service;
  HomeWidgetMock homeWidgetMock;
  AnalyticsService analyticsService;

  group("AppWidgetServiceTest - ", () {
    setUp(() {
      service = AppWidgetService();
      homeWidgetMock = HomeWidgetMock();

      analyticsService = setupAnalyticsServiceMock();
    });

    tearDown(() {
      // TODO: clear home widget data ?
    });

    test("init", () async {
      homeWidgetMock.stubInit();
      expect(
          await service.init(),
          true);
    });

    test("sendProgressData is sucessful", () async {
      const String title = "Widget title";
      const double progress = 0.5;
      const int elapsedDays = 10;
      const int totalDays = 20;
      const String suffix = "d";

      final ProgressWidgetData progressWidgetData = ProgressWidgetData(
          title: title,
          progress: progress,
          elapsedDays: elapsedDays,
          totalDays: totalDays,
          suffix: suffix);

      // stub HomeWidget saveData behavior to match given input
      var listIds = [
        '${ProgressWidgetData.KEY_PREFIX}progress',
        '${ProgressWidgetData.KEY_PREFIX}elapsedDays',
        '${ProgressWidgetData.KEY_PREFIX}totalDays',
        '${ProgressWidgetData.KEY_PREFIX}suffix',
        '${ProgressWidgetData.KEY_PREFIX}title'
      ];
      var listDatas = [
        progress,
        elapsedDays,
        totalDays,
        suffix,
        title
      ];
      homeWidgetMock.stubSaveWidgetDataMock(listIds, listDatas);

      var test = await service.sendProgressData(progressWidgetData);
      expect(test, true);
    });

    test("sendProgressData stopped on error", () async {
      const String title = "Widget title";
      const double progress = 0.5;
      const int elapsedDays = 10;
      const int totalDays = 20;
      const String suffix = "d";

      final ProgressWidgetData progressWidgetData = ProgressWidgetData(
          title: title,
          progress: progress,
          elapsedDays: elapsedDays,
          totalDays: totalDays,
          suffix: suffix);

      // stub HomeWidget saveData behavior to match given input
      var listIds = [
        '${ProgressWidgetData.KEY_PREFIX}progress',
        '${ProgressWidgetData.KEY_PREFIX}elapsedDays',
        '${ProgressWidgetData.KEY_PREFIX}totalDays',
        '${ProgressWidgetData.KEY_PREFIX}suffix',
        '${ProgressWidgetData.KEY_PREFIX}title'
      ];
      var listDatas = [
        progress,
        elapsedDays,
        totalDays,
        suffix,
        "bad title blablabla"
      ];
      homeWidgetMock.stubSaveWidgetDataMock(listIds, listDatas);
      expect(() async => service.sendProgressData(progressWidgetData), throwsException,
          reason: "Data is invalid for widget");
    });

    test("sendGradesData", () async {

    });

    group("updateWidget - ", () {
      // TODO: check return values?

      test("progress", () async {
        const WidgetType type = WidgetType.progress;
        homeWidgetMock.stubUpdateWidgetMock(type.androidName, type.androidName, type.iOSname);
        expect(
            await HomeWidget.updateWidget(
                name: type.androidName, androidName: type.androidName, iOSName: type.iOSname),
            true);
      });

      test("grades", () async {
        const WidgetType type = WidgetType.grades;
        homeWidgetMock.stubUpdateWidgetMock(type.androidName, type.androidName, type.iOSname);
        expect(
            await HomeWidget.updateWidget(
                name: type.androidName, androidName: type.androidName, iOSName: type.iOSname),
            true);
      });
    });
  });
}
