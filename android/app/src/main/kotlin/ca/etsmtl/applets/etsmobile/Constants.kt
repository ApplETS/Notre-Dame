package ca.etsmtl.applets.etsmobile

object Constants {
    const val USERNAME_KEY = "usernameKey"
    const val PASSWORD_KEY = "passwordKey"

    const val SEMESTER_PROGRESS_PREFS_KEY = "SemesterProgressWidgetPrefs"
    const val SEMESTER_PROGRESS_VARIANT_KEY = "progress_variant"
    const val SEMESTER_PROGRESS_CURRENT_VARIANT_KEY = "semester_progress_text_current_variant_index"
    const val SEMESTER_PROGRESS_THEME_KEY = "theme"
    const val SEMESTER_PROGRESS_LANG_KEY = "lang"

    const val SEMESTER_PROGRESS_THEME_DARK = "DARK"
    const val SEMESTER_PROGRESS_THEME_LIGHT = "LIGHT"
    const val SEMESTER_PROGRESS_LANG_EN = "EN"
    const val SEMESTER_PROGRESS_LANG_FR = "FR"
    const val SEMESTER_PROGRESS_TITLE_EN = "Semester Progress"
    const val SEMESTER_PROGRESS_TITLE_FR = "Progression de la session"
    const val SEMESTER_PROGRESS_DAYS_EN = "days"
    const val SEMESTER_PROGRESS_DAYS_FR = "jours"
    const val SEMESTER_PROGRESS_ELAPSED_EN = "days elapsed"
    const val SEMESTER_PROGRESS_ELAPSED_FR = "jours écoulés"
    const val SEMESTER_PROGRESS_REMAINING_EN = "days remaining"
    const val SEMESTER_PROGRESS_REMAINING_FR = "jours restants"

    const val MAX_PROGRESS_VARIANT_INDEX = 2
    const val WIDGET_BUTTON_CLICK = "ca.etsmtl.applets.etsmobile.WIDGET_BUTTON_CLICK"

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