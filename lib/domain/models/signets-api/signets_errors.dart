/// Errors returned by Signets
class SignetsError {
  /// Error message returned when the schedule isn't ready or the session is too
  /// old to be saved on the system
  static const String scheduleNotAvailable = "Aucune donnée";

  static const String gradesEmpty = "GRADES_NOT_AVAILABLE";
  static const String gradesNotAvailable = "Cours ou bordereau de notes inexistant pour";
}
