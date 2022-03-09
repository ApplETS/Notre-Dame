// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:home_widget/home_widget.dart';
import 'package:mockito/mockito.dart';

// CONSTANTS
import 'package:notredame/core/constants/widget_types.dart';

// SERVICE
import 'package:notredame/core/services/app_widget_service.dart';

// MODEL
import 'package:notredame/core/models/widget_models.dart';


void main() {

  AppWidgetService service;

  // TestWidgetsFlutterBinding.ensureInitialized(); // ?

  group("AppWidgetServiceTest - ", () {
    setUp(() {
      service = AppWidgetService();
    });

    tearDown(() {
      // TODO: clear home widget data ?
    });

    test("init", () async {
      await service.init();
      verify(HomeWidget.setAppGroupId('group.ca.etsmtl.applets.ETSMobile')).called(1);  // ??
      // TODO: check return bool value?
    });

    test("sendProgressData", () async {
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

      await service.sendProgressData(progressWidgetData);

      expect(
          await HomeWidget.getWidgetData<double>('${ProgressWidgetData.KEY_PREFIX}progress'),
          progress);
      expect(
          await HomeWidget.getWidgetData<int>('${ProgressWidgetData.KEY_PREFIX}elapsedDays'),
          elapsedDays);
      expect(
          await HomeWidget.getWidgetData<int>('${ProgressWidgetData.KEY_PREFIX}totalDays'),
          totalDays);
      expect(
          await HomeWidget.getWidgetData<String>('${ProgressWidgetData.KEY_PREFIX}suffix'),
          suffix);
      expect(
          await HomeWidget.getWidgetData<String>('${ProgressWidgetData.KEY_PREFIX}title'),
          title);
    });

    test("sendGradesData", () async {
      // TODO same as sendProgressData
    });

    group("updateWidget - ", () {
      // TODO: check return values?

      test("progress", () async {
        const WidgetType type = WidgetType.progress;
        verify(HomeWidget.updateWidget(
        name: type.androidName, androidName: type.androidName, iOSName: type.iOSname)).called(1);
      });

      test("grades", () async {
        const WidgetType type = WidgetType.grades;
        verify(HomeWidget.updateWidget(
        name: type.androidName, androidName: type.androidName, iOSName: type.iOSname)).called(1);
      });
    });
  });
}
