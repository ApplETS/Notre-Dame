// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:home_widget/home_widget.dart';

// Project imports:
import 'package:notredame/core/constants/widget_helper.dart';
import 'package:notredame/core/models/widget_models.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/locator.dart';

// MODEL

// CONSTANTS

// MANAGER / SERVICE

// OTHER

/// Manage the app widget function to update data and visual.
class AppWidgetService {
  static const String tag = "AppWidgetService";

  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  Future<bool> init() async {
    return HomeWidget.setAppGroupId('group.ca.etsmtl.applets.ETSMobile');
  }

  /// Update session progress widget with provided data
  Future<bool> sendProgressData(ProgressWidgetData progressWidgetData) async {
    try {
      await HomeWidget.saveWidgetData<int>(
          '${ProgressWidgetData.keyPrefix}progressInt',
          (progressWidgetData.progress * 100).round());
      await HomeWidget.saveWidgetData<double>(
          '${ProgressWidgetData.keyPrefix}progress',
          progressWidgetData.progress);
      await HomeWidget.saveWidgetData<int>(
          '${ProgressWidgetData.keyPrefix}elapsedDays',
          progressWidgetData.elapsedDays);
      await HomeWidget.saveWidgetData<int>(
          '${ProgressWidgetData.keyPrefix}totalDays',
          progressWidgetData.totalDays);
      await HomeWidget.saveWidgetData<String>(
          '${ProgressWidgetData.keyPrefix}suffix', progressWidgetData.suffix);
      return await HomeWidget.saveWidgetData<String>(
          '${ProgressWidgetData.keyPrefix}title', progressWidgetData.title);
    } on PlatformException {
      _analyticsService.logError(
          tag, 'Error sending data to session progress widget.');
      rethrow;
    }
  }

  /// Update grades widget with provided data
  Future<bool> sendGradesData(GradesWidgetData gradeWidgetData) async {
    try {
      await HomeWidget.saveWidgetData<List<String>>(
          '${GradesWidgetData.keyPrefix}courseAcronyms',
          gradeWidgetData.courseAcronyms);
      await HomeWidget.saveWidgetData<List<String>>(
          '${GradesWidgetData.keyPrefix}grades', gradeWidgetData.grades);
      return await HomeWidget.saveWidgetData<String>(
          '${GradesWidgetData.keyPrefix}title', gradeWidgetData.title);
    } on PlatformException {
      _analyticsService.logError(tag, 'Error sending data to grades widget.');
      rethrow;
    }
  }

  /// Tell the system to update the given widget type
  Future<void> updateWidget(WidgetType type) async {
    try {
      return HomeWidget.updateWidget(
          name: type.androidName,
          androidName: type.androidName,
          iOSName: type.iOSname);
    } on PlatformException {
      _analyticsService.logError(tag, 'Error updating widget ${type.iOSname}.');
    }
  }
}
