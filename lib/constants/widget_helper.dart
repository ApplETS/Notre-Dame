/// An enum for all kinds of supported home screen widgets
enum WidgetType { progress, grades }

/// The extension corresponding to WidgetType to get associated constants
extension WidgetTypeExtension on WidgetType {
  /// ID used by iOS systems to update the corresponding widget
  String? get iOSname {
    switch (this) {
      case WidgetType.progress:
        return 'ETSMobile_ProgressWidget';
      case WidgetType.grades:
        return 'ETSMobile_GradesWidget';
      default:
        return null;
    }
  }

  /// ID used by Android systems to update the corresponding widget
  ///
  /// This MUST be equal to the classname of the Android WidgetProvider (see
  /// home_widget's README for more info)
  ///
  /// Another option would be to use qualifiedAndroidName instead of androidName
  /// (see home_widget's updateWidget method for more info)
  String? get androidName {
    switch (this) {
      case WidgetType.progress:
        return 'ProgressWidgetProvider';
      case WidgetType.grades:
        return 'GradesWidgetProvider';
      default:
        return null;
    }
  }

  /// Task IDs used by the system's work manager (unused at the moment)
  // static const String progressTaskId = "app_widget_progress";
  // static const String gradesTaskId = "app_widget_grades";
}
