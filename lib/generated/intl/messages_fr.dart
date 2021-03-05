// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'fr';

  static m0(grade) => "${grade}%";

  static m1(grade, maxGrade, inPercentage) => "${grade}/${maxGrade} (${inPercentage}%)";

  static m2(number) => "Groupe ${number}";

  static m3(weight) => "Pondération : ${weight}%";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "abbreviation_not_available" : MessageLookupByLibrary.simpleMessage("ND"),
    "card_applets_text" : MessageLookupByLibrary.simpleMessage("ÉTSMobile a été conçue par le club ApplETS. Supportez-nous en aimant notre page Facebook, en contribuant sur GitHub ou en nous faisant part de vos commentaires par courriel."),
    "card_applets_title" : MessageLookupByLibrary.simpleMessage("ApplETS"),
    "card_schedule_no_seances_today" : MessageLookupByLibrary.simpleMessage("Aucune séance de cours à l\'horaire aujourd\'hui"),
    "dark_theme" : MessageLookupByLibrary.simpleMessage("Foncé"),
    "dashboard_msg_card_removed" : MessageLookupByLibrary.simpleMessage("Carte supprimée"),
    "dashboard_restore_all_cards_title" : MessageLookupByLibrary.simpleMessage("Restaurer toutes les cartes"),
    "email" : MessageLookupByLibrary.simpleMessage("Courriel"),
    "error" : MessageLookupByLibrary.simpleMessage("Une erreur est survenue"),
    "error_no_email_app" : MessageLookupByLibrary.simpleMessage("Aucune application de courriel disponible"),
    "error_no_internet_connection" : MessageLookupByLibrary.simpleMessage("Aucune connexion Internet"),
    "ets_bibliotech_title" : MessageLookupByLibrary.simpleMessage("Bibliotech"),
    "ets_directory_title" : MessageLookupByLibrary.simpleMessage("Bottin"),
    "ets_heuristique_title" : MessageLookupByLibrary.simpleMessage("L\'heuristique"),
    "ets_monets_title" : MessageLookupByLibrary.simpleMessage("MonÉTS"),
    "ets_moodle_title" : MessageLookupByLibrary.simpleMessage("Moodle"),
    "ets_news_title" : MessageLookupByLibrary.simpleMessage("Nouvelles"),
    "ets_security_title" : MessageLookupByLibrary.simpleMessage("Sécurité"),
    "facebook" : MessageLookupByLibrary.simpleMessage("Facebook"),
    "github" : MessageLookupByLibrary.simpleMessage("GitHub"),
    "grades_average" : MessageLookupByLibrary.simpleMessage("Moyenne"),
    "grades_current_rating" : MessageLookupByLibrary.simpleMessage("Votre note"),
    "grades_grade" : MessageLookupByLibrary.simpleMessage("Note"),
    "grades_grade_in_percentage" : m0,
    "grades_grade_with_percentage" : m1,
    "grades_group" : MessageLookupByLibrary.simpleMessage("Groupe"),
    "grades_group_number" : m2,
    "grades_median" : MessageLookupByLibrary.simpleMessage("Médiane"),
    "grades_msg_no_grades" : MessageLookupByLibrary.simpleMessage("Aucune note disponible"),
    "grades_percentile_rank" : MessageLookupByLibrary.simpleMessage("Rang centile"),
    "grades_standard_deviation" : MessageLookupByLibrary.simpleMessage("Écart-type"),
    "grades_target_date" : MessageLookupByLibrary.simpleMessage("Date cible"),
    "grades_title" : MessageLookupByLibrary.simpleMessage("Notes"),
    "grades_weight" : m3,
    "light_theme" : MessageLookupByLibrary.simpleMessage("Pâle"),
    "login_action_sign_in" : MessageLookupByLibrary.simpleMessage("Se connecter"),
    "login_applets_logo" : MessageLookupByLibrary.simpleMessage("Conçue par"),
    "login_error_field_required" : MessageLookupByLibrary.simpleMessage("Ce champ est requis"),
    "login_error_incorrect_password" : MessageLookupByLibrary.simpleMessage("Le mot de passe est erroné"),
    "login_error_invalid_password" : MessageLookupByLibrary.simpleMessage("Ce mot de passe est erroné"),
    "login_error_invalid_universal_code" : MessageLookupByLibrary.simpleMessage("Le code universel est invalide"),
    "login_info_universal_code" : MessageLookupByLibrary.simpleMessage("Votre code d\'accès universel est sous la forme AB12345. Celui-ci vous a été transmis par le Bureau du registraire lors de votre admission."),
    "login_msg_logout_success" : MessageLookupByLibrary.simpleMessage("Vous vous êtes déconnecté"),
    "login_prompt_password" : MessageLookupByLibrary.simpleMessage("Mot de passe"),
    "login_prompt_universal_code" : MessageLookupByLibrary.simpleMessage("Code universel"),
    "login_title" : MessageLookupByLibrary.simpleMessage("Connexion"),
    "more_about_applets_title" : MessageLookupByLibrary.simpleMessage("À propos d\'ApplETS"),
    "more_applets_about_details" : MessageLookupByLibrary.simpleMessage("ÉTSMobile a été réalisée par le club scientifique ApplETS de l\'École de technologie supérieure.\n\nApplETS se veut, avant tout, un regroupement d’étudiants qui partagent un intérêt commun pour le domaine des télécommunications et des applications mobiles. La mission d\'ApplETS est de former les étudiants au développement mobile et de promouvoir la production d\'applications mobiles au sein de la communauté étudiante.\n\nSuivez-nous sur : "),
    "more_beta_faq" : MessageLookupByLibrary.simpleMessage("FAQ Bêta"),
    "more_contributors" : MessageLookupByLibrary.simpleMessage("Contributeurs"),
    "more_log_out" : MessageLookupByLibrary.simpleMessage("Se déconnecter"),
    "more_log_out_progress" : MessageLookupByLibrary.simpleMessage("Déconnexion en cours"),
    "more_open_source_licenses" : MessageLookupByLibrary.simpleMessage("Licences des logiciels libres"),
    "more_prompt_log_out_confirmation" : MessageLookupByLibrary.simpleMessage("Êtes-vous certain de vouloir vous déconnecter?"),
    "more_prompt_report_bug_method" : MessageLookupByLibrary.simpleMessage("Comment souhaitez-vous rapporter le bogue?"),
    "more_report_bug" : MessageLookupByLibrary.simpleMessage("Rapporter un bogue"),
    "more_report_bug_method_screenshot" : MessageLookupByLibrary.simpleMessage("Capture d\'écran"),
    "more_report_bug_method_video" : MessageLookupByLibrary.simpleMessage("Capture vidéo"),
    "more_settings" : MessageLookupByLibrary.simpleMessage("Paramètres"),
    "no" : MessageLookupByLibrary.simpleMessage("Non"),
    "profile_average_program" : MessageLookupByLibrary.simpleMessage("Moyenne"),
    "profile_balance" : MessageLookupByLibrary.simpleMessage("Solde"),
    "profile_code_program" : MessageLookupByLibrary.simpleMessage("Code"),
    "profile_first_name" : MessageLookupByLibrary.simpleMessage("Prénom"),
    "profile_last_name" : MessageLookupByLibrary.simpleMessage("Nom de famille"),
    "profile_number_accumulated_credits_program" : MessageLookupByLibrary.simpleMessage("Crédits complétés"),
    "profile_number_completed_courses_program" : MessageLookupByLibrary.simpleMessage("Cours réussis"),
    "profile_number_equivalent_courses_program" : MessageLookupByLibrary.simpleMessage("Cours d\'équivalence"),
    "profile_number_failed_courses_program" : MessageLookupByLibrary.simpleMessage("Cours échoués"),
    "profile_number_registered_credits_program" : MessageLookupByLibrary.simpleMessage("Crédits inscrits"),
    "profile_permanent_code" : MessageLookupByLibrary.simpleMessage("Code permanent"),
    "profile_personal_information_title" : MessageLookupByLibrary.simpleMessage("Informations personnelles"),
    "profile_status_program" : MessageLookupByLibrary.simpleMessage("Statut"),
    "profile_student_status_title" : MessageLookupByLibrary.simpleMessage("État du dossier étudiant"),
    "profile_title" : MessageLookupByLibrary.simpleMessage("Profil"),
    "retry" : MessageLookupByLibrary.simpleMessage("Réessayer"),
    "schedule_no_event" : MessageLookupByLibrary.simpleMessage("Aucun évènements à l\'horaire."),
    "schedule_settings_calendar_format_2_weeks" : MessageLookupByLibrary.simpleMessage("2 semaines"),
    "schedule_settings_calendar_format_month" : MessageLookupByLibrary.simpleMessage("Mois"),
    "schedule_settings_calendar_format_pref" : MessageLookupByLibrary.simpleMessage("Format du calendrier"),
    "schedule_settings_calendar_format_week" : MessageLookupByLibrary.simpleMessage("Semaine"),
    "schedule_settings_show_today_btn_pref" : MessageLookupByLibrary.simpleMessage("Afficher le bouton Aujourd\'hui"),
    "schedule_settings_starting_weekday_friday" : MessageLookupByLibrary.simpleMessage("Vendredi"),
    "schedule_settings_starting_weekday_monday" : MessageLookupByLibrary.simpleMessage("Lundi"),
    "schedule_settings_starting_weekday_pref" : MessageLookupByLibrary.simpleMessage("Premier jour de la semaine"),
    "schedule_settings_starting_weekday_saturday" : MessageLookupByLibrary.simpleMessage("Samedi"),
    "schedule_settings_starting_weekday_sunday" : MessageLookupByLibrary.simpleMessage("Dimanche"),
    "schedule_settings_starting_weekday_thursday" : MessageLookupByLibrary.simpleMessage("Jeudi"),
    "schedule_settings_starting_weekday_tuesday" : MessageLookupByLibrary.simpleMessage("Mardi"),
    "schedule_settings_starting_weekday_wednesday" : MessageLookupByLibrary.simpleMessage("Mercredi"),
    "schedule_settings_title" : MessageLookupByLibrary.simpleMessage("Paramètres de l\'horaire"),
    "security_armed_person_detail" : MessageLookupByLibrary.simpleMessage("armed_person_detail_fr.html"),
    "security_armed_person_title" : MessageLookupByLibrary.simpleMessage("Personne armée"),
    "security_bomb_threat_detail" : MessageLookupByLibrary.simpleMessage("bomb_threat_detail_fr.html"),
    "security_bomb_threat_title" : MessageLookupByLibrary.simpleMessage("Alerte à la bombe"),
    "security_broken_elevator_detail" : MessageLookupByLibrary.simpleMessage("broken_elevator_detail_fr.html"),
    "security_broken_elevator_title" : MessageLookupByLibrary.simpleMessage("Panne d\'ascenseur"),
    "security_earthquake_detail" : MessageLookupByLibrary.simpleMessage("earthquake_detail_fr.html"),
    "security_earthquake_title" : MessageLookupByLibrary.simpleMessage("Tremblement de terre"),
    "security_electrical_outage_detail" : MessageLookupByLibrary.simpleMessage("electrical_outage_detail_fr.html"),
    "security_electrical_outage_title" : MessageLookupByLibrary.simpleMessage("Panne électrique"),
    "security_emergency_call" : MessageLookupByLibrary.simpleMessage("Appel d\'urgence"),
    "security_emergency_intern_call" : MessageLookupByLibrary.simpleMessage("À l\'interne"),
    "security_emergency_intern_number" : MessageLookupByLibrary.simpleMessage("Poste 55"),
    "security_emergency_number" : MessageLookupByLibrary.simpleMessage("514 396–8900"),
    "security_emergency_procedures" : MessageLookupByLibrary.simpleMessage("Procédures d\'urgence"),
    "security_evacuation_detail" : MessageLookupByLibrary.simpleMessage("evacuation_detail_fr.html"),
    "security_evacuation_title" : MessageLookupByLibrary.simpleMessage("Évacuation"),
    "security_fire_detail" : MessageLookupByLibrary.simpleMessage("fire_detail_fr.html"),
    "security_fire_title" : MessageLookupByLibrary.simpleMessage("Incendie"),
    "security_gas_leak_detail" : MessageLookupByLibrary.simpleMessage("gas_leak_detail_fr.html"),
    "security_gas_leak_title" : MessageLookupByLibrary.simpleMessage("Fuite de gaz"),
    "security_medical_emergency_detail" : MessageLookupByLibrary.simpleMessage("medical_emergency_detail_fr.html"),
    "security_medical_emergency_title" : MessageLookupByLibrary.simpleMessage("Urgence médicale"),
    "security_reach_security" : MessageLookupByLibrary.simpleMessage("Joindre la sécurité"),
    "security_station" : MessageLookupByLibrary.simpleMessage("Poste de sécurité"),
    "security_suspicious_packages_detail" : MessageLookupByLibrary.simpleMessage("suspicious_packages_detail_fr.html"),
    "security_suspicious_packages_title" : MessageLookupByLibrary.simpleMessage("Colis suspect"),
    "session_fall" : MessageLookupByLibrary.simpleMessage("Automne"),
    "session_summer" : MessageLookupByLibrary.simpleMessage("Été"),
    "session_winter" : MessageLookupByLibrary.simpleMessage("Hiver"),
    "session_without" : MessageLookupByLibrary.simpleMessage("Sans trimestre"),
    "settings_dark_theme_pref" : MessageLookupByLibrary.simpleMessage("Thème"),
    "settings_display_pref_category" : MessageLookupByLibrary.simpleMessage("Affichage"),
    "settings_english" : MessageLookupByLibrary.simpleMessage("English"),
    "settings_french" : MessageLookupByLibrary.simpleMessage("Français"),
    "settings_language_pref" : MessageLookupByLibrary.simpleMessage("Langue"),
    "settings_miscellaneous_category" : MessageLookupByLibrary.simpleMessage("Divers"),
    "settings_title" : MessageLookupByLibrary.simpleMessage("Paramètres"),
    "system_theme" : MessageLookupByLibrary.simpleMessage("Système"),
    "thankYouForTheFeedback" : MessageLookupByLibrary.simpleMessage("Merci pour le signalement"),
    "title_dashboard" : MessageLookupByLibrary.simpleMessage("Accueil"),
    "title_ets" : MessageLookupByLibrary.simpleMessage("ÉTS"),
    "title_more" : MessageLookupByLibrary.simpleMessage("Plus"),
    "title_schedule" : MessageLookupByLibrary.simpleMessage("Horaire"),
    "title_student" : MessageLookupByLibrary.simpleMessage("Étudiant"),
    "yes" : MessageLookupByLibrary.simpleMessage("Oui")
  };
}
