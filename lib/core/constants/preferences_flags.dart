import 'package:flutter/cupertino.dart';

enum PreferencesFlag {
  // Schedule flags
  scheduleSettingsCalendarFormat,
  scheduleSettingsStartWeekday,
  scheduleSettingsShowTodayBtn,
  scheduleSettingsLaboratoryGroupCourse,

  // Locale flag
  locale,

  // Theme flag
  theme,

  // Choose language flag
  languageChoice,

  // Discovery flag
  discovery,

  // Dashboard flags
  aboutUsCard,
  scheduleCard,
  progressBarCard,
  gradesCard
}

/// This class can be used instead of the conventional enum to save data to shared Prefs,
/// if your key value should be decided at runtime.
class DynamicPreferencesFlag {
  final String separator;
  String specialKey;
  PreferencesFlag groupAssociationFlag;

  DynamicPreferencesFlag(
      {@required this.groupAssociationFlag,
      @required this.specialKey,
      this.separator = "_"});

  String get data => groupAssociationFlag.toString() + separator + specialKey;
}
