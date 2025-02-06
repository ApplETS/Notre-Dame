enum PreferencesFlag {
  // Schedule flags
  scheduleCalendarFormat,
  scheduleShowTodayBtn,
  scheduleLaboratoryGroup,
  scheduleListView,

  // Locale flag
  locale,

  // Theme flag
  theme,

  // Choose language flag
  languageChoice,

  // Dashboard flags
  aboutUsCard,
  scheduleCard,
  progressBarCard,
  gradesCard,
  progressBarText,

  // Rating flag
  ratingTimer,
  hasRatingBeenRequested,

  // Issues flag
  ghIssues,
}

/// This class can be used instead of the conventional enum to save data to shared Prefs,
/// if your key value should be decided at runtime.
class DynamicPreferencesFlag {
  final String separator;
  String uniqueKey;
  PreferencesFlag groupAssociationFlag;

  DynamicPreferencesFlag(
      {required this.groupAssociationFlag,
      required this.uniqueKey,
      this.separator = "_"});

  String get data => groupAssociationFlag.toString() + separator + uniqueKey;

  @override
  String toString() {
    return groupAssociationFlag.name + separator + uniqueKey;
  }

  @override
  bool operator ==(Object other) =>
      other is DynamicPreferencesFlag &&
      groupAssociationFlag == other.groupAssociationFlag &&
      separator == other.separator &&
      uniqueKey == other.uniqueKey;

  @override
  int get hashCode =>
      groupAssociationFlag.hashCode ^ separator.hashCode ^ uniqueKey.hashCode;
}
