// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/locator.dart';
import 'package:workmanager/workmanager.dart';

mixin AppWidgetUtils {

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
          name: 'ETSMobile_WidgetProvider', androidName:'HomeWidgetExampleProvider', iOSName: 'ETSMobile_Widget');
    } on PlatformException catch (exception) {
      debugPrint('Error Updating Widget. $exception');
      locator<AnalyticsService>().logError('AppWidgetUtils', 'Error updating widget.');
    }
  }

  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) {
      print("Native called background task: $task"); //simpleTask will be emitted here.
      return Future.value(true);
    });
  }
  static void initWorkManager() {
    HomeWidget.setAppGroupId('group.ca.etsmtl.applets.ETSMobile');
    Workmanager().initialize(
        callbackDispatcher, // The top level function, aka callbackDispatcher
        isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
    );
  }
}
