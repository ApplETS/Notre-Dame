// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/locator.dart';
import 'package:workmanager/workmanager.dart';

mixin AppWidgetUtils {
  static const String appWidgetProgressTaskId = "app_widget_progress";
  static double progress = 0.0;
  static Future<void> sendProgressData(double progress) async {
    try {
      return await HomeWidget.saveWidgetData<double>('progress', progress);
    } on PlatformException catch (exception) {
      debugPrint('Error Sending Data. $exception');
      locator<AnalyticsService>().logError('AppWidgetUtils', 'Error sending data to progress bar widget.');
    }
  }

  static Future<void> updateWidget() async {
    try {
      return HomeWidget.updateWidget(
          name: 'ETSMobile_WidgetProvider', androidName:'HomeWidgetExampleProvider', iOSName: 'ETSMobile_ProgressWidget');
    } on PlatformException catch (exception) {
      debugPrint('Error Updating Widget. $exception');
      locator<AnalyticsService>().logError('AppWidgetUtils', 'Error updating widget.');
    }
  }

  static void _callbackDispatcher() {
    Workmanager().executeTask((task, inputData) {
      switch (task) {
        case appWidgetProgressTaskId:
          progress += 0.1;
          sendProgressData(progress).then((_) {
            updateWidget();
          });
          print(progress);
        break;
      }
      print("Background processing task");
      return Future.value(true);
    });
  }
  static Future<void> initWorkManager() async {
    HomeWidget.setAppGroupId('group.ca.etsmtl.applets.ETSMobile');
    await Workmanager().initialize(
        _callbackDispatcher, // The top level function, aka callbackDispatcher
        isInDebugMode: kDebugMode // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
    );

    Workmanager().registerPeriodicTask(
      "main_background_thread",
      appWidgetProgressTaskId,
      frequency: const Duration(seconds: 1),
    );
  }
}
