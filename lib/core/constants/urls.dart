/// List of the URLS used by the different services
class Urls {
  // Urls related to MonETS
  static const String monEtsAPI = "https://portail.etsmtl.ca/api/";
  static const String authenticationMonETS = "${monEtsAPI}authentification";

  /// Urls related to SignetsMobile API
  /// For more information about the operations supported see:
  /// https://signets-ens.etsmtl.ca/Secure/WebServices/SignetsMobile.asmx
  static const String signetsAPI = "https://signets-ens.etsmtl.ca/Secure/WebServices/SignetsMobile.asmx";

  // SOAP Operations supported by the Signets API
  static const String signetsOperationBase = "http://etsmtl.ca/";
  static const String listClassScheduleOperation = "lireHoraireDesSeances";
}