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

  /// Urls related to SignetsMobile API
  /// For more information about the operations supported see:
  static const String signetsAPI = "etsmobileapi-preprod.etsmtl.ca";

  // Operations supported by the Signets API
  static const String infoStudentOperation = "/api/Etudiant/infoEtudiant";
  static const String listProgramsOperation = "/api/Etudiant/listeProgrammes";
  static const String listClassScheduleOperation = "/api/Etudiant/lireHoraireDesSeances";
  static const String listSessionsOperation = "/api/Etudiant/listeSessions";
  static const String listCourseOperation = "/api/Etudiant/listeCours";
  static const String listEvaluationsOperation = "/api/Etudiant/listeElementsEvaluation";
  static const String listeHoraireEtProf = "/api/Etudiant/listeHoraireEtProf";
  static const String readCourseReviewOperation = "/api/Etudiant/lireEvaluationCours";
}
