// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

// CONSTANTS
import 'package:notredame/core/constants/widget_types.dart';
import 'package:notredame/core/models/widget_models.dart';

// MANAGER / SERVICE
import 'package:notredame/core/services/analytics_service.dart';

// OTHER
import 'package:notredame/locator.dart';


/// Manage the app widget function to update data and visual.
class AppWidgetService {
  static const String TAG = "AppWidgetService";

  Future init() async {
    await HomeWidget.setAppGroupId('group.ca.etsmtl.applets.ETSMobile');
  }

  /// Update session progress widget with provided data
  Future<void> sendProgressData(ProgressWidgetData progressWidgetData) async {
    try {
      await HomeWidget.saveWidgetData<double>('${ProgressWidgetData.KEY_PREFIX}progress', progressWidgetData.progress);
      await HomeWidget.saveWidgetData<int>('${ProgressWidgetData.KEY_PREFIX}elapsedDays', progressWidgetData.elapsedDays);
      await HomeWidget.saveWidgetData<int>('${ProgressWidgetData.KEY_PREFIX}totalDays', progressWidgetData.totalDays);
      await HomeWidget.saveWidgetData<String>('${ProgressWidgetData.KEY_PREFIX}suffix', progressWidgetData.suffix);
      return await HomeWidget.saveWidgetData<String>('${ProgressWidgetData.KEY_PREFIX}title', progressWidgetData.title);
    } on PlatformException catch (exception) {
      locator<AnalyticsService>().logError(TAG, 'Error sending data to session progress widget.');
    }
  }

  /// Update grades widget with provided data
  Future<void> sendGradesData(GradesWidgetData gradeWidgetData) async {
    try {
      var res = await HomeWidget.saveWidgetData<List<String>>('${GradesWidgetData.KEY_PREFIX}courseAcronyms', gradeWidgetData.courseAcronyms);
      res = res && await HomeWidget.saveWidgetData<List<String>>('${GradesWidgetData.KEY_PREFIX}grades', gradeWidgetData.grades);
      res = res && await HomeWidget.saveWidgetData<String>('${GradesWidgetData.KEY_PREFIX}title', gradeWidgetData.title);
      if (!res) {
        locator<AnalyticsService>().logError(TAG, 'Error saving grades widget data.');
      }
    } on PlatformException catch (exception) {
      locator<AnalyticsService>().logError(TAG, 'Error sending data to grades widget.');
    }
  }

  /// Tell the system to update the given widget type
  Future<void> updateWidget(WidgetType type) async {
    try {
      return HomeWidget.updateWidget(
          name: type.androidName, androidName: type.androidName, iOSName: type.iOSname);
    } on PlatformException catch (exception) {
      debugPrint('Error Updating Widget. $exception');
      locator<AnalyticsService>().logError(TAG, 'Error updating widget ${type.iOSname}.');
    }
  }

}
