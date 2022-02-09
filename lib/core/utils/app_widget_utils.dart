// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

// CONSTANTS
import 'package:notredame/core/constants/widget_types.dart';

// MANAGER / SERVICE
import 'package:notredame/core/services/analytics_service.dart';

// OTHER
import 'package:notredame/locator.dart';

/// Utils interfacing Flutter with iOS widgets
mixin AppWidgetUtils {

  static double progress = 0.0; // debug

  /// Update session progress widget with provided data
  static Future<void> sendProgressData(double progress, int elapsedDays, int totalDays) async {
    try {
      await HomeWidget.saveWidgetData<double>('progress', progress);
      await HomeWidget.saveWidgetData<int>('elapsedDays', elapsedDays);
      return await HomeWidget.saveWidgetData<int>('totalDays', totalDays);
    } on PlatformException catch (exception) {
      locator<AnalyticsService>().logError('AppWidgetUtils', 'Error sending data to session progress widget.');
    }
  }

  /// Update grades widget with provided data
  static Future<void> sendGradesData(List<String> courseAcronyms, List<String> grades) async {
    try {
      var res = await HomeWidget.saveWidgetData<List<String>>('courseAcronyms', courseAcronyms);
      res &= await HomeWidget.saveWidgetData<List<String>>('grades', grades);
      if (!res) {
        locator<AnalyticsService>().logError('AppWidgetUtils', 'Error saving grades widget data.');
      }
    } on PlatformException catch (exception) {
      locator<AnalyticsService>().logError('AppWidgetUtils', 'Error sending data to grades widget.');
    }
  }

  /// Tell the system to update the given widget type
  static Future<void> updateWidget(WidgetType type) async {
    try {
      return HomeWidget.updateWidget(
          name: type.androidName, androidName: type.androidName, iOSName: type.iOSname);
    } on PlatformException catch (exception) {
      debugPrint('Error Updating Widget. $exception');
      locator<AnalyticsService>().logError('AppWidgetUtils', 'Error updating widget ${type.iOSname}.');
    }
  }

  /// Background update (not working ATM)
  static void _callbackDispatcher() {
    Workmanager().executeTask((task, inputData) {
      switch (task) {
        case WidgetTypeExtension.progressTaskId:
          // FIXME not working atm
          progress += 0.1;
          sendProgressData(progress, 0, 100).then((_) {
            updateWidget(WidgetType.progress);
          });
          print(progress);    // debug
        break;
      }
      print("Background processing task");    // debug
      return Future.value(true);
    });
  }

  /// Initialize work manager for background widget updates
  static Future<void> initWorkManager() async {
    HomeWidget.setAppGroupId('group.ca.etsmtl.applets.ETSMobile');
    await Workmanager().initialize(
        _callbackDispatcher, // The top level function, aka callbackDispatcher
        isInDebugMode: kDebugMode // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
    );

    // Register existing widget tasks
    Workmanager().registerPeriodicTask(
      "main_background_thread",
      WidgetTypeExtension.progressTaskId,
      frequency: const Duration(minutes: 15),
    );
  }
}
