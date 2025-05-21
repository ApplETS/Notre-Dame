// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppIntlFr extends AppIntl {
  AppIntlFr([String locale = 'fr']) : super(locale);

  @override
  String get error => 'Une erreur est survenue';

  @override
  String get error_no_internet_connection => 'Aucune connexion Internet';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get retry => 'Réessayer';

  @override
  String get session_fall => 'Automne';

  @override
  String get session_winter => 'Hiver';

  @override
  String get session_summer => 'Été';

  @override
  String get session_without => 'Pas de session active';

  @override
  String get link => 'Lien';

  @override
  String get social_links => 'Liens sociaux';

  @override
  String get facebook => 'Facebook';

  @override
  String get github => 'GitHub';

  @override
  String get email => 'Courriel';

  @override
  String get email_subject => 'Problème ÉTSMobile';

  @override
  String get website_open => 'Visiter le site web';

  @override
  String get website_club_open => 'Visiter le site web du club';

  @override
  String get facebook_open => 'Visiter notre page Facebook';

  @override
  String get instagram_open => 'Visiter notre page Instagram';

  @override
  String get github_open => 'Visiter notre page GitHub';

  @override
  String get youtube_open => 'Visiter notre page Youtube';

  @override
  String get email_send => 'Envoyer un commentaire via courriel';

  @override
  String get discord_join => 'Rejoidre notre Discord';

  @override
  String get faq_questions => 'Questions et réponses';

  @override
  String get faq_questions_no_access_title => 'Je n’ai pas accès au cours et au programme.';

  @override
  String get faq_questions_no_access_description =>
      'Les nouveaux étudiants pourraient ne pas voir l’horaire et les cours inscrits avant le début de la première session de cours. Cependant, ces informations apparaissent dès le début de la première session de cours.';

  @override
  String get faq_questions_no_grades_title => 'Je ne vois plus mes notes.';

  @override
  String get faq_questions_no_grades_description =>
      'Il est possible qu’il s’agit de la période d\'évaluation des cours. Vous devez compléter les évaluations sur SignETS. Les notes seront disponibles après avoir répondu aux évaluations.';

  @override
  String get faq_actions => 'Actions';

  @override
  String get faq_actions_reactivate_account_title =>
      'Je suis diplômé de l’ÉTS et je souhaite faire réactiver mon compte.';

  @override
  String get faq_actions_reactivate_account_description => 'Vous pouvez demander de réactiver votre compte.';

  @override
  String get faq_actions_contact_registrar_title =>
      'Questions concernant vos conditions d\'admission, des inscriptions et des conditions relatives à la poursuite de vos études';

  @override
  String get faq_actions_contact_registrar_description => 'Veuillez contacter le Bureau de la registraire.';

  @override
  String get faq_actions_contact_applets_title => 'Questions concernant l’application ÉTSMobile';

  @override
  String get faq_actions_contact_applets_description => 'Veuillez contacter App|ETS.';

  @override
  String get need_help_notice_title => 'Attention';

  @override
  String get need_help_notice_description =>
      'Veuillez noter que si votre question concerne l\'accès à votre compte, le club App|ETS ne peut pas vous aider. \n\nAppuyez sur le bouton \"Assistance mot de passe\" pour obtenir de l\'aide';

  @override
  String get need_help_notice_password_assistance => 'Assistance mot de passe';

  @override
  String get need_help_notice_send_email => 'Rédiger un courriel';

  @override
  String get need_help_notice_cancel => 'Annuler';

  @override
  String get close_button_text => 'Fermer';

  @override
  String get title_schedule => 'Horaire';

  @override
  String get title_student => 'Étudiant';

  @override
  String get title_dashboard => 'Accueil';

  @override
  String get title_ets => 'ÉTS';

  @override
  String get title_more => 'Plus';

  @override
  String get title_ets_mobile => 'ÉTSMobile';

  @override
  String get login_title => 'Connexion';

  @override
  String get login_prompt_universal_code => 'Code universel';

  @override
  String get login_prompt_password => 'Mot de passe';

  @override
  String get login_action_sign_in => 'Se connecter';

  @override
  String get login_error_invalid_universal_code => 'Ce code universel est invalide';

  @override
  String get login_error_field_required => 'Ce champ est requis';

  @override
  String get login_error_invalid_credentials => 'Identifiants invalides. Possiblement une erreur côté serveur.';

  @override
  String get login_info_universal_code =>
      'Votre code d\'accès universel est sous la forme AB12345. Celui-ci vous a été transmis par le Bureau du registraire lors de votre admission.';

  @override
  String get login_msg_logout_success => 'Vous vous êtes déconnecté';

  @override
  String get login_applets_logo => 'Conçue par';

  @override
  String get login_password_forgotten => 'Mot de passe oublié?';

  @override
  String get login_password_show => 'Afficher le mot de passe';

  @override
  String get login_password_hide => 'Cacher le mot de passe';

  @override
  String get dashboard_msg_card_removed => 'Carte supprimée';

  @override
  String get dashboard_restore_all_cards_title => 'Restaurer toutes les cartes';

  @override
  String get card_schedule_tomorrow => ' - demain';

  @override
  String get card_applets_title => 'ApplETS';

  @override
  String get card_applets_text =>
      'ÉTSMobile a été conçue par le club ApplETS. Supportez-nous en aimant notre page Facebook, en contribuant sur GitHub ou en nous faisant part de vos commentaires par courriel.';

  @override
  String get error_no_email_app => 'Aucune application de courriel disponible';

  @override
  String get schedule_settings_title => 'Paramètres de l\'horaire';

  @override
  String get schedule_settings_show_today_btn_pref => 'Afficher le bouton Aujourd\'hui';

  @override
  String get schedule_settings_calendar_format_pref => 'Format du calendrier';

  @override
  String get schedule_settings_calendar_format_day => 'Jour';

  @override
  String get schedule_settings_calendar_format_month => 'Mois';

  @override
  String get schedule_settings_calendar_format_week => 'Semaine';

  @override
  String get schedule_settings_starting_weekday_pref => 'Premier jour de la semaine';

  @override
  String get schedule_settings_show_weekend_day => 'Afficher la fin de semaine';

  @override
  String get schedule_settings_show_weekend_day_none => 'Aucun';

  @override
  String get schedule_settings_show_week_events_btn_pref => 'Afficher les activités de la semaine';

  @override
  String get schedule_settings_list_view => 'Liste défilante';

  @override
  String get schedule_settings_starting_weekday_monday => 'Lundi';

  @override
  String get schedule_settings_starting_weekday_tuesday => 'Mardi';

  @override
  String get schedule_settings_starting_weekday_wednesday => 'Mercredi';

  @override
  String get schedule_settings_starting_weekday_thursday => 'Jeudi';

  @override
  String get schedule_settings_starting_weekday_friday => 'Vendredi';

  @override
  String get schedule_settings_starting_weekday_saturday => 'Samedi';

  @override
  String get schedule_settings_starting_weekday_sunday => 'Dimanche';

  @override
  String get schedule_no_event => 'Aucun évènement à l\'horaire.';

  @override
  String get schedule_select_course_activity => 'Sélectionner le groupe du laboratoire';

  @override
  String get schedule_already_today_tooltip => 'Aller à l\'horaire d\'aujourd\'hui';

  @override
  String get schedule_already_today_toast => 'Déjà sur l\'horaire d\'aujourd\'hui';

  @override
  String get schedule_calendar_from => 'Du';

  @override
  String get schedule_calendar_to => 'au';

  @override
  String get schedule_calendar_from_time => 'De';

  @override
  String get schedule_calendar_to_time => 'à';

  @override
  String get schedule_calendar_by => 'Par';

  @override
  String get course_activity_group_a => 'Groupe A';

  @override
  String get course_activity_group_b => 'Groupe B';

  @override
  String get course_activity_group_both => 'Les deux';

  @override
  String get calendar_new => 'Nouveau calendrier';

  @override
  String get calendar_export => 'Exporter vers le calendrier';

  @override
  String get calendar_export_success => 'Horaire exporté avec succès';

  @override
  String get calendar_export_error => 'Un ou plusieurs événements n\'ont pas pu être exportés correctement';

  @override
  String get calendar_export_question => 'Vers quel calendrier voulez-vous exporter cet événement?';

  @override
  String get calendar_name => 'Nom du calendrier';

  @override
  String get calendar_select => 'Veuillez sélectionner un calendrier';

  @override
  String get calendar_cancel_button => 'Annuler';

  @override
  String get calendar_export_button => 'Exporter';

  @override
  String get calendar_permission_denied_modal_title => 'Permission Refusée';

  @override
  String get calendar_permission_denied =>
      'Vous n\'avez pas accordé la permission d\'accéder à votre calendrier. Veuillez l\'activer dans les paramètres système de l\'application.';

  @override
  String get grades_title => 'Notes';

  @override
  String grades_in_schedule(String sessionNameYear) {
    return 'Naviguer à l\'horaire : $sessionNameYear';
  }

  @override
  String get grades_msg_no_grades => 'Aucune note disponible.\nTirez pour rafraichir';

  @override
  String get grades_msg_no_grade => 'Aucune note disponible';

  @override
  String get grades_current_rating => 'Votre note';

  @override
  String get grades_average => 'Moyenne';

  @override
  String grades_grade_in_percentage(Object grade) {
    return '$grade %';
  }

  @override
  String grades_grade_with_percentage(double grade, Object maxGrade, double inPercentage) {
    return '$grade/$maxGrade ($inPercentage %)';
  }

  @override
  String grades_weight(double weight) {
    return 'Pondération : $weight %';
  }

  @override
  String get grades_group => 'Groupe';

  @override
  String get grades_grade => 'Note';

  @override
  String get grades_median => 'Médiane';

  @override
  String get grades_weighted => 'Pondérée';

  @override
  String get grades_standard_deviation => 'Écart-type';

  @override
  String get grades_percentile_rank => 'Rang centile';

  @override
  String get grades_target_date => 'Date cible';

  @override
  String get grades_ignored_evaluation_title => 'Évaluation ignorée';

  @override
  String get grades_ignored_evaluation_details =>
      'Cette évaluation est ignorée dans le calcul de la note finale. Cette situation se produit quand l\'enseignant a décidé de conserver, par exemple, les trois meilleures notes des six devoirs qu\'il a demandés. Les trois notes les plus faibles seront alors ignorées.';

  @override
  String get grades_error_failed_to_retrieve_data_course => 'Échec de la récupération des données de ce cours';

  @override
  String get grades_summary_section_title => 'Sommaire';

  @override
  String get grades_evaluations_section_title => 'Évaluations';

  @override
  String grades_group_number(String number) {
    return 'Groupe $number';
  }

  @override
  String credits_number(int number) {
    return 'Crédits: $number';
  }

  @override
  String grades_teacher(String teacherName) {
    return 'Enseignant: $teacherName';
  }

  @override
  String get grades_error_course_evaluations_not_completed =>
      'Vous n\'aurez pas accès à vos notes au cours de la période d\'évaluation tant que vous n\'aurez pas effectué vos évaluations.';

  @override
  String get grades_not_available => 'ND';

  @override
  String get profile_title => 'Profil';

  @override
  String get profile_student_status_title => 'État du dossier étudiant';

  @override
  String get profile_personal_information_title => 'Informations personnelles';

  @override
  String get profile_first_name => 'Prénom';

  @override
  String get profile_last_name => 'Nom de famille';

  @override
  String get profile_permanent_code => 'Code permanent';

  @override
  String get profile_permanent_code_copied_to_clipboard => 'Code permanent copié dans le presse-papier';

  @override
  String get profile_universal_code_copied_to_clipboard => 'Code universel copié dans le presse-papier';

  @override
  String get profile_balance => 'Votre solde';

  @override
  String get profile_code_program => 'Code';

  @override
  String get profile_average_program => 'Moyenne';

  @override
  String get profile_number_accumulated_credits_program => 'Crédits complétés';

  @override
  String get profile_number_registered_credits_program => 'Crédits inscrits';

  @override
  String get profile_number_completed_courses_program => 'Cours réussis';

  @override
  String get profile_number_failed_courses_program => 'Cours échoués';

  @override
  String get profile_number_equivalent_courses_program => 'Cours d\'équivalence';

  @override
  String get profile_status_program => 'Statut';

  @override
  String get profile_program_completion => 'Complétion du programme';

  @override
  String get profile_program_completion_not_available => 'ND';

  @override
  String get profile_other_programs => 'Autres Programmes';

  @override
  String get useful_link_title => 'Liens utiles';

  @override
  String get ets_security_title => 'Sécurité';

  @override
  String get ets_monets_title => 'MonÉTS';

  @override
  String get ets_bibliotech_title => 'Bibliotech';

  @override
  String get ets_news_title => 'Nouvelles';

  @override
  String get ets_moodle_title => 'Moodle';

  @override
  String get ets_directory_title => 'Bottin';

  @override
  String get ets_heuristique_title => 'L\'heuristique';

  @override
  String get ets_schedule_generator => 'HorairÉTS';

  @override
  String get ets_gus => 'GUS';

  @override
  String get ets_papercut_title => 'PaperCut';

  @override
  String get ets_aeets_title => 'AÉÉTS';

  @override
  String get ets_100genies_title => 'Pub 100 Génies';

  @override
  String get ets_stages_et_emplois_title => 'Stages et emplois';

  @override
  String get ets_eportfolio_title => 'ePortfolio';

  @override
  String get ets_ebourses_title => 'eBourses';

  @override
  String ets_hide_quick_link(String quickLinkName) {
    return 'Masquer le lien : $quickLinkName';
  }

  @override
  String ets_add_quick_link(String quickLinkName) {
    return 'Ajouter le lien : $quickLinkName';
  }

  @override
  String get share => 'Partager';

  @override
  String get export => 'Exporter';

  @override
  String get news_title => 'Annonces';

  @override
  String get news_details_title => 'Annonce';

  @override
  String get news_event_date => 'Date de l\'événement';

  @override
  String get news_error_not_found_title => 'Oh oh!';

  @override
  String get news_error_not_found =>
      'Une erreur est survenue lors de la récupération des annonces. Veuillez réessayer plus tard.';

  @override
  String get news_no_more_card_title => 'Vous êtes à jour!';

  @override
  String get news_no_more_card =>
      'Vous avez atteint la fin des annonces. Revenez plus tard pour voir les prochaines annonces!';

  @override
  String get news_export_success => 'L\'annonce a été exporté avec succès';

  @override
  String get news_export_error => 'Une erreur est survenue lors de l\'exportation de l\'événement';

  @override
  String get report_news => 'Pourquoi signalez-vous cette annonce ?';

  @override
  String get report_as => 'Signaler comme';

  @override
  String get report => 'Signaler';

  @override
  String get report_toast => 'Merci pour votre signalement ! ';

  @override
  String get report_reason_hint => 'Commentaire';

  @override
  String get report_inappropriate_content => 'Contenu inapproprié';

  @override
  String get report_inappropriate_content_description =>
      'Annonce contenant des discours haineux, des images choquantes, ou du contenu adulte.';

  @override
  String get report_false_information => 'Information fausse ou trompeuse';

  @override
  String get report_false_information_description => 'Annonce qui semble être fausse ou qui induit en erreur.';

  @override
  String get report_harassment_or_abuse => 'Harcèlement ou abus';

  @override
  String get report_harassment_or_abuse_description => 'Annonce ciblant une personne ou un groupe de manière abusive.';

  @override
  String get report_outdated_content => 'Contenu obsolète';

  @override
  String get report_outdated_content_description => 'Annonce qui n’est plus d\'actualité ou pertinente.';

  @override
  String get search => 'Rechercher';

  @override
  String get news_author_notify_me => 'Me notifier';

  @override
  String get news_author_dont_notify_me => 'Ne plus recevoir de notifications';

  @override
  String get news_author_join_us => 'Nous rejoindre';

  @override
  String news_author_notified_for(String author) {
    return 'Vous recevrez une notification lorsque $author publiera une annonce.';
  }

  @override
  String news_author_not_notified_for(String author) {
    return 'Vous ne recevrez plus une notification lorsque $author publiera une annonce.';
  }

  @override
  String get more_about_applets_title => 'À propos d\'ApplETS';

  @override
  String get more_report_bug => 'Rapporter un bogue ou une amélioration';

  @override
  String get more_report_bug_steps_title => 'Comment faire?\n\n';

  @override
  String get more_report_bug_button => 'Fournir un avis';

  @override
  String get more_prompt_report_bug_method => 'Comment souhaitez-vous rapporter le bogue?';

  @override
  String get more_report_bug_method_screenshot => 'Capture d\'écran';

  @override
  String get more_report_bug_method_video => 'Capture vidéo';

  @override
  String get more_contributors => 'Contributeurs';

  @override
  String get more_open_source_licenses => 'Licences des logiciels libres';

  @override
  String get more_settings => 'Paramètres';

  @override
  String get more_log_out => 'Se déconnecter';

  @override
  String get more_prompt_log_out_confirmation => 'Êtes-vous certain de vouloir vous déconnecter?';

  @override
  String get more_log_out_progress => 'Déconnexion en cours';

  @override
  String get more_applets_about_details =>
      'ÉTSMobile a été réalisée par le club scientifique ApplETS de l\'École de technologie supérieure.\n\nApplETS se veut, avant tout, un regroupement d’étudiants qui partagent un intérêt commun pour le domaine des télécommunications et des applications mobiles. La mission d\'ApplETS est de former les étudiants au développement mobile et de promouvoir la production d\'applications mobiles au sein de la communauté étudiante.\n\nSuivez-nous sur : ';

  @override
  String get more_report_bug_bug => 'Rapporter un bogue';

  @override
  String get more_report_bug_bug_subtitle =>
      '\nFaites-le nous savoir afin que nous puissions l\'ajouter à notre liste de bogues.';

  @override
  String get more_report_bug_feature => 'Demander une fonctionnalité';

  @override
  String get more_report_bug_feature_subtitle =>
      '\nAvez-vous une idée qui améliorerait notre application ? Nous aimerions savoir !';

  @override
  String get more_report_tips => 'Astuce';

  @override
  String get more_report_bug_step1 =>
      'Après avoir sélectionné l\'option, la vue des commentaires s\'ouvrira.\n\nVous pouvez choisir entre le mode ';

  @override
  String get more_report_bug_step2 => 'Naviguer ';

  @override
  String get more_report_bug_step3 => 'et ';

  @override
  String get more_report_bug_step4 => 'Dessiner ';

  @override
  String get more_report_bug_step5 =>
      'sur le côté droit. \n\nEn mode navigation, vous pouvez naviguer librement dans l\'application.\n\nPour passer en mode dessin, appuyez simplement sur le bouton \'Dessiner\'. Vous pouvez maintenant dessiner sur l\'écran.\n\nPour terminer votre commentaire, écrivez simplement une description ci-dessous et envoyez-la en appuyant sur le bouton \'Soumettre\'.';

  @override
  String get security_bomb_threat_title => 'Alerte à la bombe';

  @override
  String get security_bomb_threat_detail => 'bomb_threat_fr.md';

  @override
  String get security_suspicious_packages_title => 'Colis suspect';

  @override
  String get security_suspicious_packages_detail => 'suspicious_packages_fr.md';

  @override
  String get security_evacuation_title => 'Évacuation';

  @override
  String get security_evacuation_detail => 'evacuation_fr.md';

  @override
  String get security_gas_leak_title => 'Fuite de gaz';

  @override
  String get security_gas_leak_detail => 'gas_leak_fr.md';

  @override
  String get security_fire_title => 'Incendie';

  @override
  String get security_fire_detail => 'fire_fr.md';

  @override
  String get security_broken_elevator_title => 'Panne d\'ascenseur';

  @override
  String get security_broken_elevator_detail => 'broken_elevator_fr.md';

  @override
  String get security_electrical_outage_title => 'Panne électrique';

  @override
  String get security_electrical_outage_detail => 'electrical_outage_fr.md';

  @override
  String get security_armed_person_title => 'Personne armée';

  @override
  String get security_armed_person_detail => 'armed_person_fr.md';

  @override
  String get security_earthquake_title => 'Tremblement de terre';

  @override
  String get security_earthquake_detail => 'earthquake_fr.md';

  @override
  String get security_medical_emergency_title => 'Urgence médicale';

  @override
  String get security_medical_emergency_detail => 'medical_emergency_fr.md';

  @override
  String get security_emergency_call => 'Appel d\'urgence';

  @override
  String get security_reach_security => 'Joindre la sécurité';

  @override
  String get security_emergency_number => '514 396–8900';

  @override
  String get security_emergency_intern_call => 'À l\'interne';

  @override
  String get security_emergency_intern_number => 'Poste 55';

  @override
  String get security_emergency_procedures => 'Procédures d\'urgence';

  @override
  String get security_station => 'Poste de sécurité';

  @override
  String get settings_title => 'Paramètres';

  @override
  String get settings_display_pref_category => 'Affichage';

  @override
  String get settings_dark_theme_pref => 'Thème';

  @override
  String get settings_miscellaneous_category => 'Divers';

  @override
  String get settings_language_pref => 'Langue';

  @override
  String get settings_french => 'Français';

  @override
  String get settings_english => 'English';

  @override
  String get dark_theme => 'Foncé';

  @override
  String get light_theme => 'Pâle';

  @override
  String get system_theme => 'Système';

  @override
  String get thank_you_for_the_feedback => 'Merci pour le signalement';

  @override
  String get flutter_license =>
      'Flutter est la boîte à outils d\'interface utilisateur de Google pour créer de superbes applications compilées en natif pour mobile, Web et bureau à partir d\'une seule base de code. En savoir plus sur Flutter à ';

  @override
  String get flutter_website => 'https://flutter.dev';

  @override
  String get choose_language_title => 'Choisissez votre langue préférée';

  @override
  String get choose_language_subtitle => 'Veuillez sélectionner votre langue';

  @override
  String get not_found_title => 'Page introuvable';

  @override
  String not_found_message(String pageName) {
    return 'Oh oh... il semblerait que la page $pageName n\'est pas accessible.';
  }

  @override
  String get go_to_dashboard => 'Retour à l\'accueil';

  @override
  String get go_back => 'Retour';

  @override
  String get no_connectivity => 'Aucune connexion internet';

  @override
  String get service_outage =>
      'Désolé, nous éprouvons actuellement des problèmes de connexion. Veuillez réessayer plus tard.';

  @override
  String get service_outage_contact =>
      'Nous sommes au courant de la situation. Nous faisons notre possible pour la régler dans les plus courts délais.';

  @override
  String get service_outage_refresh => 'Rafraichir';

  @override
  String get progress_bar_title => 'Progression de la session';

  @override
  String progress_bar_message(int elapsedDays, int totalDays) {
    return '$elapsedDays jours écoulés / $totalDays jours';
  }

  @override
  String progress_bar_message_percentage(int percentage) {
    return '$percentage %';
  }

  @override
  String progress_bar_message_remaining_days(int remainingDays) {
    return '$remainingDays jours restants';
  }

  @override
  String get progress_bar_suffix => 'jours';

  @override
  String get in_app_review_title => 'Évaluez-nous!';

  @override
  String get need_help => 'Besoin d\'aide?';

  @override
  String get privacy_policy => 'Politique de confidentialité';

  @override
  String get universal_code_example => 'Ex: AB12345';

  @override
  String get my_tickets => 'Mes billets';

  @override
  String get no_ticket => 'Aucun billet';

  @override
  String get ticket_status_open => 'Ouvert';

  @override
  String get ticket_status_closed => 'Fermé';

  @override
  String get loading => 'Chargement...';

  @override
  String get no_schedule_available => 'Il n\'y a aucun événement à l\'horaire pour l\'instant';

  @override
  String social_links_name(String linkName) {
    return 'Lien social : $linkName';
  }
}
