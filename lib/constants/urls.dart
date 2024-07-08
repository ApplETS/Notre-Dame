/// List of the URLS used by the different services
class Urls {
  // Urls related to club websites
  static const String clubWebsite = "https://clubapplets.ca/";
  static const String clubGithub = "https://github.com/ApplETS";
  static const String clubFacebook = "https://facebook.com/ClubApplETS";
  static const String clubInstagram = "https://www.instagram.com/clubapplets";
  static const String clubTwitter = "https://twitter.com/ClubApplETS";
  static const String clubEmail = "mailto:ApplETS@etsmtl.ca";
  static const String clubYoutube =
      "https://youtube.com/channel/UCiSzzfW1bVbE_0KcEZO52ew";
  static const String clubDiscord = "https://discord.gg/adMkWptn6Y";

  // Urls related to MonETS
  static const String monEtsAPI = "https://portail.etsmtl.ca/api/";
  static const String authenticationMonETS = "${monEtsAPI}authentification";

  /// Urls related to SignetsMobile API
  /// For more information about the operations supported see:
  /// https://signets-ens.etsmtl.ca/Secure/WebServices/SignetsMobile.asmx
  static const String signetsAPI =
      "https://signets-ens.etsmtl.ca/Secure/WebServices/SignetsMobile.asmx";

  // SOAP Operations supported by the Signets API
  static const String signetsOperationBase = "http://etsmtl.ca/";
  static const String donneesAuthentificationValides =
      "donneesAuthentificationValides";
  static const String infoStudentOperation = "infoEtudiant";
  static const String listProgramsOperation = "listeProgrammes";
  static const String listClassScheduleOperation = "lireHoraireDesSeances";
  static const String listSessionsOperation = "listeSessions";
  static const String listCourseOperation = "listeCours";
  static const String listEvaluationsOperation = "listeElementsEvaluation";
  static const String listeHoraireEtProf = "listeHoraireEtProf";
  static const String readCourseReviewOperation = "lireEvaluationCours";
}
