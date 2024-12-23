/// Errors returned by Signets
class SignetsError {
  static const String credentialsInvalid =
      "Code d'accès ou mot de passe invalide";

  /// Error message returned when the schedule isn't ready or the session is too
  /// old to be saved on the system
  static const String scheduleNotAvailable = "Aucune donnée.  Cela peut être "
      "causé parce que l'horaire détaillé n'est pas encore finalisé (il l'est "
      "généralement quelques jours avant le début de la session), ou parce que "
      "l'horaire est trop ancien (nous ne gardons que 4 sessions), ou que vous "
      "n'êtes pas inscrit, ou que vous n'êtes inscrit qu'à des activité sans "
      "horaire, comme un stage ou que que vous êtes en rédaction de mémoire "
      "ou de thèse.";

  /// Error message returned when the schedule isn't ready or the session is too
  /// old to be saved on the system. Female version.
  static const String scheduleNotAvailableF = "Aucune donnée.  Cela peut être "
      "causé parce que l'horaire détaillé n'est pas encore finalisé (il l'est "
      "généralement quelques jours avant le début de la session), ou parce que "
      "l'horaire est trop ancien (nous ne gardons que 4 sessions), ou que vous "
      "n'êtes pas inscrite, ou que vous n'êtes inscrite qu'à des activité sans "
      "horaire, comme un stage ou que que vous êtes en rédaction de mémoire "
      "ou de thèse.";

  static const String gradesEmpty = "GRADES_NOT_AVAILABLE";
  static const String gradesNotAvailable =
      "Cours ou bordereau de notes inexistant pour";

  static const String signetsErrorSoapTag = "erreur";
}
