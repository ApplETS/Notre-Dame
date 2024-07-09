package ca.etsmtl.applets.etsmobile

object Constants {
    const val WIDGET_GROUP_ID = "group.ca.etsmtl.applets.ETSMobile"
    const val KEYCHAIN_SERVICE_ATTR = "flutter_keychain"
    const val USERNAME_KEY = "WidgetSecureUser"
    const val PASSWORD_KEY = "WidgetSecurePass"

    // URLs related to MonETS
    const val MON_ETS_API = "https://portail.etsmtl.ca/api/"
    const val AUTHENTICATION_MON_ETS = "${MON_ETS_API}authentification"

    // URLs related to SignetsMobile API
    // For more information about the operations supported see:
    // https://signets-ens.etsmtl.ca/Secure/WebServices/SignetsMobile.asmx
    const val SIGNETS_API = "https://signets-ens.etsmtl.ca/Secure/WebServices/SignetsMobile.asmx"

    // MonETS Constants
    const val SIGNETS_OPERATION_BASE = "http://etsmtl.ca/"
    const val DONNEES_AUTHENTIFICATION_VALIDES = "donneesAuthentificationValides"
    const val INFO_STUDENT_OPERATION = "infoEtudiant"
    const val LIST_PROGRAMS_OPERATION = "listeProgrammes"
    const val LIST_CLASS_SCHEDULE_OPERATION = "lireHoraireDesSeances"
    const val LIST_SESSIONS_OPERATION = "listeSessions"
    const val LIST_COURSE_OPERATION = "listeCours"
    const val LIST_EVALUATIONS_OPERATION = "listeElementsEvaluation"
    const val LISTE_HORAIRE_ET_PROF = "listeHoraireEtProf"
    const val READ_COURSE_REVIEW_OPERATION = "lireEvaluationCours"
}