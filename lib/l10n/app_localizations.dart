import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppIntl
/// returned by `AppIntl.of(context)`.
///
/// Applications need to include `AppIntl.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppIntl.localizationsDelegates,
///   supportedLocales: AppIntl.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppIntl.supportedLocales
/// property.
abstract class AppIntl {
  AppIntl(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppIntl? of(BuildContext context) {
    return Localizations.of<AppIntl>(context, AppIntl);
  }

  static const LocalizationsDelegate<AppIntl> delegate = _AppIntlDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('fr')];

  /// No description provided for @error.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue'**
  String get error;

  /// No description provided for @error_no_internet_connection.
  ///
  /// In fr, this message translates to:
  /// **'Aucune connexion Internet'**
  String get error_no_internet_connection;

  /// No description provided for @yes.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get no;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @session_fall.
  ///
  /// In fr, this message translates to:
  /// **'Automne'**
  String get session_fall;

  /// No description provided for @session_winter.
  ///
  /// In fr, this message translates to:
  /// **'Hiver'**
  String get session_winter;

  /// No description provided for @session_summer.
  ///
  /// In fr, this message translates to:
  /// **'Été'**
  String get session_summer;

  /// No description provided for @session_without.
  ///
  /// In fr, this message translates to:
  /// **'Pas de session active'**
  String get session_without;

  /// No description provided for @link.
  ///
  /// In fr, this message translates to:
  /// **'Lien'**
  String get link;

  /// No description provided for @social_links.
  ///
  /// In fr, this message translates to:
  /// **'Liens sociaux'**
  String get social_links;

  /// No description provided for @facebook.
  ///
  /// In fr, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @github.
  ///
  /// In fr, this message translates to:
  /// **'GitHub'**
  String get github;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'Courriel'**
  String get email;

  /// No description provided for @email_subject.
  ///
  /// In fr, this message translates to:
  /// **'Problème ÉTSMobile'**
  String get email_subject;

  /// No description provided for @website_open.
  ///
  /// In fr, this message translates to:
  /// **'Visiter le site web'**
  String get website_open;

  /// No description provided for @website_club_open.
  ///
  /// In fr, this message translates to:
  /// **'Visiter le site web du club'**
  String get website_club_open;

  /// No description provided for @facebook_open.
  ///
  /// In fr, this message translates to:
  /// **'Visiter notre page Facebook'**
  String get facebook_open;

  /// No description provided for @instagram_open.
  ///
  /// In fr, this message translates to:
  /// **'Visiter notre page Instagram'**
  String get instagram_open;

  /// No description provided for @github_open.
  ///
  /// In fr, this message translates to:
  /// **'Visiter notre page GitHub'**
  String get github_open;

  /// No description provided for @youtube_open.
  ///
  /// In fr, this message translates to:
  /// **'Visiter notre page Youtube'**
  String get youtube_open;

  /// No description provided for @email_send.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer un commentaire via courriel'**
  String get email_send;

  /// No description provided for @discord_join.
  ///
  /// In fr, this message translates to:
  /// **'Rejoidre notre Discord'**
  String get discord_join;

  /// No description provided for @faq_questions.
  ///
  /// In fr, this message translates to:
  /// **'Questions et réponses'**
  String get faq_questions;

  /// No description provided for @faq_questions_no_access_title.
  ///
  /// In fr, this message translates to:
  /// **'Je n’ai pas accès au cours et au programme.'**
  String get faq_questions_no_access_title;

  /// No description provided for @faq_questions_no_access_description.
  ///
  /// In fr, this message translates to:
  /// **'Les nouveaux étudiants pourraient ne pas voir l’horaire et les cours inscrits avant le début de la première session de cours. Cependant, ces informations apparaissent dès le début de la première session de cours.'**
  String get faq_questions_no_access_description;

  /// No description provided for @faq_questions_no_grades_title.
  ///
  /// In fr, this message translates to:
  /// **'Je ne vois plus mes notes.'**
  String get faq_questions_no_grades_title;

  /// No description provided for @faq_questions_no_grades_description.
  ///
  /// In fr, this message translates to:
  /// **'Il est possible qu’il s’agit de la période d\'évaluation des cours. Vous devez compléter les évaluations sur SignETS. Les notes seront disponibles après avoir répondu aux évaluations.'**
  String get faq_questions_no_grades_description;

  /// No description provided for @faq_actions.
  ///
  /// In fr, this message translates to:
  /// **'Actions'**
  String get faq_actions;

  /// No description provided for @faq_actions_reactivate_account_title.
  ///
  /// In fr, this message translates to:
  /// **'Je suis diplômé de l’ÉTS et je souhaite faire réactiver mon compte.'**
  String get faq_actions_reactivate_account_title;

  /// No description provided for @faq_actions_reactivate_account_description.
  ///
  /// In fr, this message translates to:
  /// **'Vous pouvez demander de réactiver votre compte.'**
  String get faq_actions_reactivate_account_description;

  /// No description provided for @faq_actions_contact_registrar_title.
  ///
  /// In fr, this message translates to:
  /// **'Questions concernant vos conditions d\'admission, des inscriptions et des conditions relatives à la poursuite de vos études'**
  String get faq_actions_contact_registrar_title;

  /// No description provided for @faq_actions_contact_registrar_description.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez contacter le Bureau de la registraire.'**
  String get faq_actions_contact_registrar_description;

  /// No description provided for @faq_actions_contact_applets_title.
  ///
  /// In fr, this message translates to:
  /// **'Questions concernant l’application ÉTSMobile'**
  String get faq_actions_contact_applets_title;

  /// No description provided for @faq_actions_contact_applets_description.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez contacter App|ETS.'**
  String get faq_actions_contact_applets_description;

  /// No description provided for @need_help_notice_title.
  ///
  /// In fr, this message translates to:
  /// **'Attention'**
  String get need_help_notice_title;

  /// No description provided for @need_help_notice_description.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez noter que si votre question concerne l\'accès à votre compte, le club App|ETS ne peut pas vous aider. \n\nAppuyez sur le bouton \"Assistance mot de passe\" pour obtenir de l\'aide'**
  String get need_help_notice_description;

  /// No description provided for @need_help_notice_password_assistance.
  ///
  /// In fr, this message translates to:
  /// **'Assistance mot de passe'**
  String get need_help_notice_password_assistance;

  /// No description provided for @need_help_notice_send_email.
  ///
  /// In fr, this message translates to:
  /// **'Rédiger un courriel'**
  String get need_help_notice_send_email;

  /// No description provided for @need_help_notice_cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get need_help_notice_cancel;

  /// No description provided for @close_button_text.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close_button_text;

  /// No description provided for @title_schedule.
  ///
  /// In fr, this message translates to:
  /// **'Horaire'**
  String get title_schedule;

  /// No description provided for @title_student.
  ///
  /// In fr, this message translates to:
  /// **'Étudiant'**
  String get title_student;

  /// No description provided for @title_dashboard.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get title_dashboard;

  /// No description provided for @title_ets.
  ///
  /// In fr, this message translates to:
  /// **'ÉTS'**
  String get title_ets;

  /// No description provided for @title_more.
  ///
  /// In fr, this message translates to:
  /// **'Plus'**
  String get title_more;

  /// No description provided for @title_ets_mobile.
  ///
  /// In fr, this message translates to:
  /// **'ÉTSMobile'**
  String get title_ets_mobile;

  /// No description provided for @login_title.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get login_title;

  /// No description provided for @login_prompt_universal_code.
  ///
  /// In fr, this message translates to:
  /// **'Code universel'**
  String get login_prompt_universal_code;

  /// No description provided for @login_prompt_password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get login_prompt_password;

  /// No description provided for @login_action_sign_in.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get login_action_sign_in;

  /// No description provided for @login_error_invalid_universal_code.
  ///
  /// In fr, this message translates to:
  /// **'Ce code universel est invalide'**
  String get login_error_invalid_universal_code;

  /// No description provided for @login_error_field_required.
  ///
  /// In fr, this message translates to:
  /// **'Ce champ est requis'**
  String get login_error_field_required;

  /// No description provided for @login_error_invalid_credentials.
  ///
  /// In fr, this message translates to:
  /// **'Identifiants invalides. Possiblement une erreur côté serveur.'**
  String get login_error_invalid_credentials;

  /// No description provided for @login_info_universal_code.
  ///
  /// In fr, this message translates to:
  /// **'Votre code d\'accès universel est sous la forme AB12345. Celui-ci vous a été transmis par le Bureau du registraire lors de votre admission.'**
  String get login_info_universal_code;

  /// No description provided for @login_msg_logout_success.
  ///
  /// In fr, this message translates to:
  /// **'Vous vous êtes déconnecté'**
  String get login_msg_logout_success;

  /// No description provided for @login_applets_logo.
  ///
  /// In fr, this message translates to:
  /// **'Conçue par'**
  String get login_applets_logo;

  /// No description provided for @login_password_forgotten.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié?'**
  String get login_password_forgotten;

  /// No description provided for @login_password_show.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le mot de passe'**
  String get login_password_show;

  /// No description provided for @login_password_hide.
  ///
  /// In fr, this message translates to:
  /// **'Cacher le mot de passe'**
  String get login_password_hide;

  /// No description provided for @dashboard_msg_card_removed.
  ///
  /// In fr, this message translates to:
  /// **'Carte supprimée'**
  String get dashboard_msg_card_removed;

  /// No description provided for @dashboard_restore_all_cards_title.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer toutes les cartes'**
  String get dashboard_restore_all_cards_title;

  /// No description provided for @card_schedule_tomorrow.
  ///
  /// In fr, this message translates to:
  /// **' - demain'**
  String get card_schedule_tomorrow;

  /// No description provided for @card_applets_title.
  ///
  /// In fr, this message translates to:
  /// **'ApplETS'**
  String get card_applets_title;

  /// No description provided for @card_applets_text.
  ///
  /// In fr, this message translates to:
  /// **'ÉTSMobile a été conçue par le club ApplETS. Supportez-nous en aimant notre page Facebook, en contribuant sur GitHub ou en nous faisant part de vos commentaires par courriel.'**
  String get card_applets_text;

  /// No description provided for @error_no_email_app.
  ///
  /// In fr, this message translates to:
  /// **'Aucune application de courriel disponible'**
  String get error_no_email_app;

  /// No description provided for @schedule_settings_title.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres de l\'horaire'**
  String get schedule_settings_title;

  /// No description provided for @schedule_settings_show_today_btn_pref.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le bouton Aujourd\'hui'**
  String get schedule_settings_show_today_btn_pref;

  /// No description provided for @schedule_settings_calendar_format_pref.
  ///
  /// In fr, this message translates to:
  /// **'Format du calendrier'**
  String get schedule_settings_calendar_format_pref;

  /// No description provided for @schedule_settings_calendar_format_day.
  ///
  /// In fr, this message translates to:
  /// **'Jour'**
  String get schedule_settings_calendar_format_day;

  /// No description provided for @schedule_settings_calendar_format_month.
  ///
  /// In fr, this message translates to:
  /// **'Mois'**
  String get schedule_settings_calendar_format_month;

  /// No description provided for @schedule_settings_calendar_format_week.
  ///
  /// In fr, this message translates to:
  /// **'Semaine'**
  String get schedule_settings_calendar_format_week;

  /// No description provided for @schedule_settings_starting_weekday_pref.
  ///
  /// In fr, this message translates to:
  /// **'Premier jour de la semaine'**
  String get schedule_settings_starting_weekday_pref;

  /// No description provided for @schedule_settings_show_weekend_day.
  ///
  /// In fr, this message translates to:
  /// **'Afficher la fin de semaine'**
  String get schedule_settings_show_weekend_day;

  /// No description provided for @schedule_settings_show_weekend_day_none.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get schedule_settings_show_weekend_day_none;

  /// No description provided for @schedule_settings_show_week_events_btn_pref.
  ///
  /// In fr, this message translates to:
  /// **'Afficher les activités de la semaine'**
  String get schedule_settings_show_week_events_btn_pref;

  /// No description provided for @schedule_settings_list_view.
  ///
  /// In fr, this message translates to:
  /// **'Liste défilante'**
  String get schedule_settings_list_view;

  /// No description provided for @schedule_settings_starting_weekday_monday.
  ///
  /// In fr, this message translates to:
  /// **'Lundi'**
  String get schedule_settings_starting_weekday_monday;

  /// No description provided for @schedule_settings_starting_weekday_tuesday.
  ///
  /// In fr, this message translates to:
  /// **'Mardi'**
  String get schedule_settings_starting_weekday_tuesday;

  /// No description provided for @schedule_settings_starting_weekday_wednesday.
  ///
  /// In fr, this message translates to:
  /// **'Mercredi'**
  String get schedule_settings_starting_weekday_wednesday;

  /// No description provided for @schedule_settings_starting_weekday_thursday.
  ///
  /// In fr, this message translates to:
  /// **'Jeudi'**
  String get schedule_settings_starting_weekday_thursday;

  /// No description provided for @schedule_settings_starting_weekday_friday.
  ///
  /// In fr, this message translates to:
  /// **'Vendredi'**
  String get schedule_settings_starting_weekday_friday;

  /// No description provided for @schedule_settings_starting_weekday_saturday.
  ///
  /// In fr, this message translates to:
  /// **'Samedi'**
  String get schedule_settings_starting_weekday_saturday;

  /// No description provided for @schedule_settings_starting_weekday_sunday.
  ///
  /// In fr, this message translates to:
  /// **'Dimanche'**
  String get schedule_settings_starting_weekday_sunday;

  /// No description provided for @schedule_no_event.
  ///
  /// In fr, this message translates to:
  /// **'Aucun évènement à l\'horaire.'**
  String get schedule_no_event;

  /// No description provided for @schedule_select_course_activity.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner le groupe du laboratoire'**
  String get schedule_select_course_activity;

  /// No description provided for @schedule_already_today_tooltip.
  ///
  /// In fr, this message translates to:
  /// **'Aller à l\'horaire d\'aujourd\'hui'**
  String get schedule_already_today_tooltip;

  /// No description provided for @schedule_already_today_toast.
  ///
  /// In fr, this message translates to:
  /// **'Déjà sur l\'horaire d\'aujourd\'hui'**
  String get schedule_already_today_toast;

  /// No description provided for @schedule_calendar_from.
  ///
  /// In fr, this message translates to:
  /// **'Du'**
  String get schedule_calendar_from;

  /// No description provided for @schedule_calendar_to.
  ///
  /// In fr, this message translates to:
  /// **'au'**
  String get schedule_calendar_to;

  /// No description provided for @schedule_calendar_from_time.
  ///
  /// In fr, this message translates to:
  /// **'De'**
  String get schedule_calendar_from_time;

  /// No description provided for @schedule_calendar_to_time.
  ///
  /// In fr, this message translates to:
  /// **'à'**
  String get schedule_calendar_to_time;

  /// No description provided for @schedule_calendar_by.
  ///
  /// In fr, this message translates to:
  /// **'Par'**
  String get schedule_calendar_by;

  /// No description provided for @course_activity_group_a.
  ///
  /// In fr, this message translates to:
  /// **'Groupe A'**
  String get course_activity_group_a;

  /// No description provided for @course_activity_group_b.
  ///
  /// In fr, this message translates to:
  /// **'Groupe B'**
  String get course_activity_group_b;

  /// No description provided for @course_activity_group_both.
  ///
  /// In fr, this message translates to:
  /// **'Les deux'**
  String get course_activity_group_both;

  /// No description provided for @calendar_new.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau calendrier'**
  String get calendar_new;

  /// No description provided for @calendar_export.
  ///
  /// In fr, this message translates to:
  /// **'Exporter vers le calendrier'**
  String get calendar_export;

  /// No description provided for @calendar_export_success.
  ///
  /// In fr, this message translates to:
  /// **'Horaire exporté avec succès'**
  String get calendar_export_success;

  /// No description provided for @calendar_export_error.
  ///
  /// In fr, this message translates to:
  /// **'Un ou plusieurs événements n\'ont pas pu être exportés correctement'**
  String get calendar_export_error;

  /// No description provided for @calendar_export_question.
  ///
  /// In fr, this message translates to:
  /// **'Vers quel calendrier voulez-vous exporter cet événement?'**
  String get calendar_export_question;

  /// No description provided for @calendar_name.
  ///
  /// In fr, this message translates to:
  /// **'Nom du calendrier'**
  String get calendar_name;

  /// No description provided for @calendar_select.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner un calendrier'**
  String get calendar_select;

  /// No description provided for @calendar_cancel_button.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get calendar_cancel_button;

  /// No description provided for @calendar_export_button.
  ///
  /// In fr, this message translates to:
  /// **'Exporter'**
  String get calendar_export_button;

  /// No description provided for @calendar_permission_denied_modal_title.
  ///
  /// In fr, this message translates to:
  /// **'Permission Refusée'**
  String get calendar_permission_denied_modal_title;

  /// No description provided for @calendar_permission_denied.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas accordé la permission d\'accéder à votre calendrier. Veuillez l\'activer dans les paramètres système de l\'application.'**
  String get calendar_permission_denied;

  /// No description provided for @grades_title.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get grades_title;

  /// No description provided for @grades_in_schedule.
  ///
  /// In fr, this message translates to:
  /// **'Naviguer à l\'horaire : {sessionNameYear}'**
  String grades_in_schedule(String sessionNameYear);

  /// No description provided for @grades_msg_no_grades.
  ///
  /// In fr, this message translates to:
  /// **'Aucune note disponible.\nTirez pour rafraichir'**
  String get grades_msg_no_grades;

  /// No description provided for @grades_msg_no_grade.
  ///
  /// In fr, this message translates to:
  /// **'Aucune note disponible'**
  String get grades_msg_no_grade;

  /// No description provided for @grades_current_rating.
  ///
  /// In fr, this message translates to:
  /// **'Votre note'**
  String get grades_current_rating;

  /// No description provided for @grades_average.
  ///
  /// In fr, this message translates to:
  /// **'Moyenne'**
  String get grades_average;

  /// No description provided for @grades_grade_in_percentage.
  ///
  /// In fr, this message translates to:
  /// **'{grade} %'**
  String grades_grade_in_percentage(Object grade);

  /// No description provided for @grades_grade_with_percentage.
  ///
  /// In fr, this message translates to:
  /// **'{grade}/{maxGrade} ({inPercentage} %)'**
  String grades_grade_with_percentage(double grade, Object maxGrade, double inPercentage);

  /// No description provided for @grades_weight.
  ///
  /// In fr, this message translates to:
  /// **'Pondération : {weight} %'**
  String grades_weight(double weight);

  /// No description provided for @grades_group.
  ///
  /// In fr, this message translates to:
  /// **'Groupe'**
  String get grades_group;

  /// No description provided for @grades_grade.
  ///
  /// In fr, this message translates to:
  /// **'Note'**
  String get grades_grade;

  /// No description provided for @grades_median.
  ///
  /// In fr, this message translates to:
  /// **'Médiane'**
  String get grades_median;

  /// No description provided for @grades_weighted.
  ///
  /// In fr, this message translates to:
  /// **'Pondérée'**
  String get grades_weighted;

  /// No description provided for @grades_standard_deviation.
  ///
  /// In fr, this message translates to:
  /// **'Écart-type'**
  String get grades_standard_deviation;

  /// No description provided for @grades_percentile_rank.
  ///
  /// In fr, this message translates to:
  /// **'Rang centile'**
  String get grades_percentile_rank;

  /// No description provided for @grades_target_date.
  ///
  /// In fr, this message translates to:
  /// **'Date cible'**
  String get grades_target_date;

  /// No description provided for @grades_ignored_evaluation_title.
  ///
  /// In fr, this message translates to:
  /// **'Évaluation ignorée'**
  String get grades_ignored_evaluation_title;

  /// No description provided for @grades_ignored_evaluation_details.
  ///
  /// In fr, this message translates to:
  /// **'Cette évaluation est ignorée dans le calcul de la note finale. Cette situation se produit quand l\'enseignant a décidé de conserver, par exemple, les trois meilleures notes des six devoirs qu\'il a demandés. Les trois notes les plus faibles seront alors ignorées.'**
  String get grades_ignored_evaluation_details;

  /// No description provided for @grades_error_failed_to_retrieve_data_course.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la récupération des données de ce cours'**
  String get grades_error_failed_to_retrieve_data_course;

  /// No description provided for @grades_summary_section_title.
  ///
  /// In fr, this message translates to:
  /// **'Sommaire'**
  String get grades_summary_section_title;

  /// No description provided for @grades_evaluations_section_title.
  ///
  /// In fr, this message translates to:
  /// **'Évaluations'**
  String get grades_evaluations_section_title;

  /// No description provided for @grades_group_number.
  ///
  /// In fr, this message translates to:
  /// **'Groupe {number}'**
  String grades_group_number(String number);

  /// No description provided for @credits_number.
  ///
  /// In fr, this message translates to:
  /// **'Crédits: {number}'**
  String credits_number(int number);

  /// No description provided for @grades_teacher.
  ///
  /// In fr, this message translates to:
  /// **'Enseignant: {teacherName}'**
  String grades_teacher(String teacherName);

  /// No description provided for @grades_error_course_evaluations_not_completed.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'aurez pas accès à vos notes au cours de la période d\'évaluation tant que vous n\'aurez pas effectué vos évaluations.'**
  String get grades_error_course_evaluations_not_completed;

  /// No description provided for @grades_not_available.
  ///
  /// In fr, this message translates to:
  /// **'ND'**
  String get grades_not_available;

  /// No description provided for @profile_title.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profile_title;

  /// No description provided for @profile_student_status_title.
  ///
  /// In fr, this message translates to:
  /// **'État du dossier étudiant'**
  String get profile_student_status_title;

  /// No description provided for @profile_personal_information_title.
  ///
  /// In fr, this message translates to:
  /// **'Informations personnelles'**
  String get profile_personal_information_title;

  /// No description provided for @profile_first_name.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get profile_first_name;

  /// No description provided for @profile_last_name.
  ///
  /// In fr, this message translates to:
  /// **'Nom de famille'**
  String get profile_last_name;

  /// No description provided for @profile_permanent_code.
  ///
  /// In fr, this message translates to:
  /// **'Code permanent'**
  String get profile_permanent_code;

  /// No description provided for @profile_permanent_code_copied_to_clipboard.
  ///
  /// In fr, this message translates to:
  /// **'Code permanent copié dans le presse-papier'**
  String get profile_permanent_code_copied_to_clipboard;

  /// No description provided for @profile_universal_code_copied_to_clipboard.
  ///
  /// In fr, this message translates to:
  /// **'Code universel copié dans le presse-papier'**
  String get profile_universal_code_copied_to_clipboard;

  /// No description provided for @profile_balance.
  ///
  /// In fr, this message translates to:
  /// **'Votre solde'**
  String get profile_balance;

  /// No description provided for @profile_code_program.
  ///
  /// In fr, this message translates to:
  /// **'Code'**
  String get profile_code_program;

  /// No description provided for @profile_average_program.
  ///
  /// In fr, this message translates to:
  /// **'Moyenne'**
  String get profile_average_program;

  /// No description provided for @profile_number_accumulated_credits_program.
  ///
  /// In fr, this message translates to:
  /// **'Crédits complétés'**
  String get profile_number_accumulated_credits_program;

  /// No description provided for @profile_number_registered_credits_program.
  ///
  /// In fr, this message translates to:
  /// **'Crédits inscrits'**
  String get profile_number_registered_credits_program;

  /// No description provided for @profile_number_completed_courses_program.
  ///
  /// In fr, this message translates to:
  /// **'Cours réussis'**
  String get profile_number_completed_courses_program;

  /// No description provided for @profile_number_failed_courses_program.
  ///
  /// In fr, this message translates to:
  /// **'Cours échoués'**
  String get profile_number_failed_courses_program;

  /// No description provided for @profile_number_equivalent_courses_program.
  ///
  /// In fr, this message translates to:
  /// **'Cours d\'équivalence'**
  String get profile_number_equivalent_courses_program;

  /// No description provided for @profile_status_program.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get profile_status_program;

  /// No description provided for @profile_program_completion.
  ///
  /// In fr, this message translates to:
  /// **'Complétion du programme'**
  String get profile_program_completion;

  /// No description provided for @profile_program_completion_not_available.
  ///
  /// In fr, this message translates to:
  /// **'ND'**
  String get profile_program_completion_not_available;

  /// No description provided for @profile_other_programs.
  ///
  /// In fr, this message translates to:
  /// **'Autres Programmes'**
  String get profile_other_programs;

  /// No description provided for @useful_link_title.
  ///
  /// In fr, this message translates to:
  /// **'Liens utiles'**
  String get useful_link_title;

  /// No description provided for @ets_security_title.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get ets_security_title;

  /// No description provided for @ets_monets_title.
  ///
  /// In fr, this message translates to:
  /// **'MonÉTS'**
  String get ets_monets_title;

  /// No description provided for @ets_bibliotech_title.
  ///
  /// In fr, this message translates to:
  /// **'Bibliotech'**
  String get ets_bibliotech_title;

  /// No description provided for @ets_news_title.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelles'**
  String get ets_news_title;

  /// No description provided for @ets_moodle_title.
  ///
  /// In fr, this message translates to:
  /// **'Moodle'**
  String get ets_moodle_title;

  /// No description provided for @ets_directory_title.
  ///
  /// In fr, this message translates to:
  /// **'Bottin'**
  String get ets_directory_title;

  /// No description provided for @ets_heuristique_title.
  ///
  /// In fr, this message translates to:
  /// **'L\'heuristique'**
  String get ets_heuristique_title;

  /// No description provided for @ets_schedule_generator.
  ///
  /// In fr, this message translates to:
  /// **'HorairÉTS'**
  String get ets_schedule_generator;

  /// No description provided for @ets_gus.
  ///
  /// In fr, this message translates to:
  /// **'GUS'**
  String get ets_gus;

  /// No description provided for @ets_papercut_title.
  ///
  /// In fr, this message translates to:
  /// **'PaperCut'**
  String get ets_papercut_title;

  /// No description provided for @ets_aeets_title.
  ///
  /// In fr, this message translates to:
  /// **'AÉÉTS'**
  String get ets_aeets_title;

  /// No description provided for @ets_100genies_title.
  ///
  /// In fr, this message translates to:
  /// **'Pub 100 Génies'**
  String get ets_100genies_title;

  /// No description provided for @ets_stages_et_emplois_title.
  ///
  /// In fr, this message translates to:
  /// **'Stages et emplois'**
  String get ets_stages_et_emplois_title;

  /// No description provided for @ets_eportfolio_title.
  ///
  /// In fr, this message translates to:
  /// **'ePortfolio'**
  String get ets_eportfolio_title;

  /// No description provided for @ets_ebourses_title.
  ///
  /// In fr, this message translates to:
  /// **'eBourses'**
  String get ets_ebourses_title;

  /// No description provided for @ets_hide_quick_link.
  ///
  /// In fr, this message translates to:
  /// **'Masquer le lien : {quickLinkName}'**
  String ets_hide_quick_link(String quickLinkName);

  /// No description provided for @ets_add_quick_link.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter le lien : {quickLinkName}'**
  String ets_add_quick_link(String quickLinkName);

  /// No description provided for @share.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get share;

  /// No description provided for @export.
  ///
  /// In fr, this message translates to:
  /// **'Exporter'**
  String get export;

  /// No description provided for @news_title.
  ///
  /// In fr, this message translates to:
  /// **'Annonces'**
  String get news_title;

  /// No description provided for @news_details_title.
  ///
  /// In fr, this message translates to:
  /// **'Annonce'**
  String get news_details_title;

  /// No description provided for @news_event_date.
  ///
  /// In fr, this message translates to:
  /// **'Date de l\'événement'**
  String get news_event_date;

  /// No description provided for @news_error_not_found_title.
  ///
  /// In fr, this message translates to:
  /// **'Oh oh!'**
  String get news_error_not_found_title;

  /// No description provided for @news_error_not_found.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue lors de la récupération des annonces. Veuillez réessayer plus tard.'**
  String get news_error_not_found;

  /// No description provided for @news_no_more_card_title.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes à jour!'**
  String get news_no_more_card_title;

  /// No description provided for @news_no_more_card.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez atteint la fin des annonces. Revenez plus tard pour voir les prochaines annonces!'**
  String get news_no_more_card;

  /// No description provided for @news_export_success.
  ///
  /// In fr, this message translates to:
  /// **'L\'annonce a été exporté avec succès'**
  String get news_export_success;

  /// No description provided for @news_export_error.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue lors de l\'exportation de l\'événement'**
  String get news_export_error;

  /// No description provided for @report_news.
  ///
  /// In fr, this message translates to:
  /// **'Pourquoi signalez-vous cette annonce ?'**
  String get report_news;

  /// No description provided for @report_as.
  ///
  /// In fr, this message translates to:
  /// **'Signaler comme'**
  String get report_as;

  /// No description provided for @report.
  ///
  /// In fr, this message translates to:
  /// **'Signaler'**
  String get report;

  /// No description provided for @report_toast.
  ///
  /// In fr, this message translates to:
  /// **'Merci pour votre signalement ! '**
  String get report_toast;

  /// No description provided for @report_reason_hint.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire'**
  String get report_reason_hint;

  /// No description provided for @report_inappropriate_content.
  ///
  /// In fr, this message translates to:
  /// **'Contenu inapproprié'**
  String get report_inappropriate_content;

  /// No description provided for @report_inappropriate_content_description.
  ///
  /// In fr, this message translates to:
  /// **'Annonce contenant des discours haineux, des images choquantes, ou du contenu adulte.'**
  String get report_inappropriate_content_description;

  /// No description provided for @report_false_information.
  ///
  /// In fr, this message translates to:
  /// **'Information fausse ou trompeuse'**
  String get report_false_information;

  /// No description provided for @report_false_information_description.
  ///
  /// In fr, this message translates to:
  /// **'Annonce qui semble être fausse ou qui induit en erreur.'**
  String get report_false_information_description;

  /// No description provided for @report_harassment_or_abuse.
  ///
  /// In fr, this message translates to:
  /// **'Harcèlement ou abus'**
  String get report_harassment_or_abuse;

  /// No description provided for @report_harassment_or_abuse_description.
  ///
  /// In fr, this message translates to:
  /// **'Annonce ciblant une personne ou un groupe de manière abusive.'**
  String get report_harassment_or_abuse_description;

  /// No description provided for @report_outdated_content.
  ///
  /// In fr, this message translates to:
  /// **'Contenu obsolète'**
  String get report_outdated_content;

  /// No description provided for @report_outdated_content_description.
  ///
  /// In fr, this message translates to:
  /// **'Annonce qui n’est plus d\'actualité ou pertinente.'**
  String get report_outdated_content_description;

  /// No description provided for @search.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get search;

  /// No description provided for @news_author_notify_me.
  ///
  /// In fr, this message translates to:
  /// **'Me notifier'**
  String get news_author_notify_me;

  /// No description provided for @news_author_dont_notify_me.
  ///
  /// In fr, this message translates to:
  /// **'Ne plus recevoir de notifications'**
  String get news_author_dont_notify_me;

  /// No description provided for @news_author_join_us.
  ///
  /// In fr, this message translates to:
  /// **'Nous rejoindre'**
  String get news_author_join_us;

  /// No description provided for @news_author_notified_for.
  ///
  /// In fr, this message translates to:
  /// **'Vous recevrez une notification lorsque {author} publiera une annonce.'**
  String news_author_notified_for(String author);

  /// No description provided for @news_author_not_notified_for.
  ///
  /// In fr, this message translates to:
  /// **'Vous ne recevrez plus une notification lorsque {author} publiera une annonce.'**
  String news_author_not_notified_for(String author);

  /// No description provided for @more_about_applets_title.
  ///
  /// In fr, this message translates to:
  /// **'À propos d\'ApplETS'**
  String get more_about_applets_title;

  /// No description provided for @more_report_bug.
  ///
  /// In fr, this message translates to:
  /// **'Rapporter un bogue ou une amélioration'**
  String get more_report_bug;

  /// No description provided for @more_report_bug_steps_title.
  ///
  /// In fr, this message translates to:
  /// **'Comment faire?\n\n'**
  String get more_report_bug_steps_title;

  /// No description provided for @more_report_bug_button.
  ///
  /// In fr, this message translates to:
  /// **'Fournir un avis'**
  String get more_report_bug_button;

  /// No description provided for @more_prompt_report_bug_method.
  ///
  /// In fr, this message translates to:
  /// **'Comment souhaitez-vous rapporter le bogue?'**
  String get more_prompt_report_bug_method;

  /// No description provided for @more_report_bug_method_screenshot.
  ///
  /// In fr, this message translates to:
  /// **'Capture d\'écran'**
  String get more_report_bug_method_screenshot;

  /// No description provided for @more_report_bug_method_video.
  ///
  /// In fr, this message translates to:
  /// **'Capture vidéo'**
  String get more_report_bug_method_video;

  /// No description provided for @more_contributors.
  ///
  /// In fr, this message translates to:
  /// **'Contributeurs'**
  String get more_contributors;

  /// No description provided for @more_open_source_licenses.
  ///
  /// In fr, this message translates to:
  /// **'Licences des logiciels libres'**
  String get more_open_source_licenses;

  /// No description provided for @more_settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get more_settings;

  /// No description provided for @more_log_out.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get more_log_out;

  /// No description provided for @more_prompt_log_out_confirmation.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous certain de vouloir vous déconnecter?'**
  String get more_prompt_log_out_confirmation;

  /// No description provided for @more_log_out_progress.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion en cours'**
  String get more_log_out_progress;

  /// No description provided for @more_applets_about_details.
  ///
  /// In fr, this message translates to:
  /// **'ÉTSMobile a été réalisée par le club scientifique ApplETS de l\'École de technologie supérieure.\n\nApplETS se veut, avant tout, un regroupement d’étudiants qui partagent un intérêt commun pour le domaine des télécommunications et des applications mobiles. La mission d\'ApplETS est de former les étudiants au développement mobile et de promouvoir la production d\'applications mobiles au sein de la communauté étudiante.\n\nSuivez-nous sur : '**
  String get more_applets_about_details;

  /// No description provided for @more_report_bug_bug.
  ///
  /// In fr, this message translates to:
  /// **'Rapporter un bogue'**
  String get more_report_bug_bug;

  /// No description provided for @more_report_bug_bug_subtitle.
  ///
  /// In fr, this message translates to:
  /// **'\nFaites-le nous savoir afin que nous puissions l\'ajouter à notre liste de bogues.'**
  String get more_report_bug_bug_subtitle;

  /// No description provided for @more_report_bug_feature.
  ///
  /// In fr, this message translates to:
  /// **'Demander une fonctionnalité'**
  String get more_report_bug_feature;

  /// No description provided for @more_report_bug_feature_subtitle.
  ///
  /// In fr, this message translates to:
  /// **'\nAvez-vous une idée qui améliorerait notre application ? Nous aimerions savoir !'**
  String get more_report_bug_feature_subtitle;

  /// No description provided for @more_report_tips.
  ///
  /// In fr, this message translates to:
  /// **'Astuce'**
  String get more_report_tips;

  /// No description provided for @more_report_bug_step1.
  ///
  /// In fr, this message translates to:
  /// **'Après avoir sélectionné l\'option, la vue des commentaires s\'ouvrira.\n\nVous pouvez choisir entre le mode '**
  String get more_report_bug_step1;

  /// No description provided for @more_report_bug_step2.
  ///
  /// In fr, this message translates to:
  /// **'Naviguer '**
  String get more_report_bug_step2;

  /// No description provided for @more_report_bug_step3.
  ///
  /// In fr, this message translates to:
  /// **'et '**
  String get more_report_bug_step3;

  /// No description provided for @more_report_bug_step4.
  ///
  /// In fr, this message translates to:
  /// **'Dessiner '**
  String get more_report_bug_step4;

  /// No description provided for @more_report_bug_step5.
  ///
  /// In fr, this message translates to:
  /// **'sur le côté droit. \n\nEn mode navigation, vous pouvez naviguer librement dans l\'application.\n\nPour passer en mode dessin, appuyez simplement sur le bouton \'Dessiner\'. Vous pouvez maintenant dessiner sur l\'écran.\n\nPour terminer votre commentaire, écrivez simplement une description ci-dessous et envoyez-la en appuyant sur le bouton \'Soumettre\'.'**
  String get more_report_bug_step5;

  /// No description provided for @security_bomb_threat_title.
  ///
  /// In fr, this message translates to:
  /// **'Alerte à la bombe'**
  String get security_bomb_threat_title;

  /// No description provided for @security_bomb_threat_detail.
  ///
  /// In fr, this message translates to:
  /// **'bomb_threat_fr.md'**
  String get security_bomb_threat_detail;

  /// No description provided for @security_suspicious_packages_title.
  ///
  /// In fr, this message translates to:
  /// **'Colis suspect'**
  String get security_suspicious_packages_title;

  /// No description provided for @security_suspicious_packages_detail.
  ///
  /// In fr, this message translates to:
  /// **'suspicious_packages_fr.md'**
  String get security_suspicious_packages_detail;

  /// No description provided for @security_evacuation_title.
  ///
  /// In fr, this message translates to:
  /// **'Évacuation'**
  String get security_evacuation_title;

  /// No description provided for @security_evacuation_detail.
  ///
  /// In fr, this message translates to:
  /// **'evacuation_fr.md'**
  String get security_evacuation_detail;

  /// No description provided for @security_gas_leak_title.
  ///
  /// In fr, this message translates to:
  /// **'Fuite de gaz'**
  String get security_gas_leak_title;

  /// No description provided for @security_gas_leak_detail.
  ///
  /// In fr, this message translates to:
  /// **'gas_leak_fr.md'**
  String get security_gas_leak_detail;

  /// No description provided for @security_fire_title.
  ///
  /// In fr, this message translates to:
  /// **'Incendie'**
  String get security_fire_title;

  /// No description provided for @security_fire_detail.
  ///
  /// In fr, this message translates to:
  /// **'fire_fr.md'**
  String get security_fire_detail;

  /// No description provided for @security_broken_elevator_title.
  ///
  /// In fr, this message translates to:
  /// **'Panne d\'ascenseur'**
  String get security_broken_elevator_title;

  /// No description provided for @security_broken_elevator_detail.
  ///
  /// In fr, this message translates to:
  /// **'broken_elevator_fr.md'**
  String get security_broken_elevator_detail;

  /// No description provided for @security_electrical_outage_title.
  ///
  /// In fr, this message translates to:
  /// **'Panne électrique'**
  String get security_electrical_outage_title;

  /// No description provided for @security_electrical_outage_detail.
  ///
  /// In fr, this message translates to:
  /// **'electrical_outage_fr.md'**
  String get security_electrical_outage_detail;

  /// No description provided for @security_armed_person_title.
  ///
  /// In fr, this message translates to:
  /// **'Personne armée'**
  String get security_armed_person_title;

  /// No description provided for @security_armed_person_detail.
  ///
  /// In fr, this message translates to:
  /// **'armed_person_fr.md'**
  String get security_armed_person_detail;

  /// No description provided for @security_earthquake_title.
  ///
  /// In fr, this message translates to:
  /// **'Tremblement de terre'**
  String get security_earthquake_title;

  /// No description provided for @security_earthquake_detail.
  ///
  /// In fr, this message translates to:
  /// **'earthquake_fr.md'**
  String get security_earthquake_detail;

  /// No description provided for @security_medical_emergency_title.
  ///
  /// In fr, this message translates to:
  /// **'Urgence médicale'**
  String get security_medical_emergency_title;

  /// No description provided for @security_medical_emergency_detail.
  ///
  /// In fr, this message translates to:
  /// **'medical_emergency_fr.md'**
  String get security_medical_emergency_detail;

  /// No description provided for @security_emergency_call.
  ///
  /// In fr, this message translates to:
  /// **'Appel d\'urgence'**
  String get security_emergency_call;

  /// No description provided for @security_reach_security.
  ///
  /// In fr, this message translates to:
  /// **'Joindre la sécurité'**
  String get security_reach_security;

  /// No description provided for @security_emergency_number.
  ///
  /// In fr, this message translates to:
  /// **'514 396–8900'**
  String get security_emergency_number;

  /// No description provided for @security_emergency_intern_call.
  ///
  /// In fr, this message translates to:
  /// **'À l\'interne'**
  String get security_emergency_intern_call;

  /// No description provided for @security_emergency_intern_number.
  ///
  /// In fr, this message translates to:
  /// **'Poste 55'**
  String get security_emergency_intern_number;

  /// No description provided for @security_emergency_procedures.
  ///
  /// In fr, this message translates to:
  /// **'Procédures d\'urgence'**
  String get security_emergency_procedures;

  /// No description provided for @security_station.
  ///
  /// In fr, this message translates to:
  /// **'Poste de sécurité'**
  String get security_station;

  /// No description provided for @settings_title.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings_title;

  /// No description provided for @settings_display_pref_category.
  ///
  /// In fr, this message translates to:
  /// **'Affichage'**
  String get settings_display_pref_category;

  /// No description provided for @settings_dark_theme_pref.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get settings_dark_theme_pref;

  /// No description provided for @settings_miscellaneous_category.
  ///
  /// In fr, this message translates to:
  /// **'Divers'**
  String get settings_miscellaneous_category;

  /// No description provided for @settings_language_pref.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settings_language_pref;

  /// No description provided for @settings_french.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get settings_french;

  /// No description provided for @settings_english.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get settings_english;

  /// No description provided for @dark_theme.
  ///
  /// In fr, this message translates to:
  /// **'Foncé'**
  String get dark_theme;

  /// No description provided for @light_theme.
  ///
  /// In fr, this message translates to:
  /// **'Pâle'**
  String get light_theme;

  /// No description provided for @system_theme.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get system_theme;

  /// No description provided for @thank_you_for_the_feedback.
  ///
  /// In fr, this message translates to:
  /// **'Merci pour le signalement'**
  String get thank_you_for_the_feedback;

  /// No description provided for @flutter_license.
  ///
  /// In fr, this message translates to:
  /// **'Flutter est la boîte à outils d\'interface utilisateur de Google pour créer de superbes applications compilées en natif pour mobile, Web et bureau à partir d\'une seule base de code. En savoir plus sur Flutter à '**
  String get flutter_license;

  /// No description provided for @flutter_website.
  ///
  /// In fr, this message translates to:
  /// **'https://flutter.dev'**
  String get flutter_website;

  /// No description provided for @choose_language_title.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre langue préférée'**
  String get choose_language_title;

  /// No description provided for @choose_language_subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner votre langue'**
  String get choose_language_subtitle;

  /// No description provided for @not_found_title.
  ///
  /// In fr, this message translates to:
  /// **'Page introuvable'**
  String get not_found_title;

  /// No description provided for @not_found_message.
  ///
  /// In fr, this message translates to:
  /// **'Oh oh... il semblerait que la page {pageName} n\'est pas accessible.'**
  String not_found_message(String pageName);

  /// No description provided for @go_to_dashboard.
  ///
  /// In fr, this message translates to:
  /// **'Retour à l\'accueil'**
  String get go_to_dashboard;

  /// No description provided for @go_back.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get go_back;

  /// No description provided for @no_connectivity.
  ///
  /// In fr, this message translates to:
  /// **'Aucune connexion internet'**
  String get no_connectivity;

  /// No description provided for @service_outage.
  ///
  /// In fr, this message translates to:
  /// **'Désolé, nous éprouvons actuellement des problèmes de connexion. Veuillez réessayer plus tard.'**
  String get service_outage;

  /// No description provided for @service_outage_contact.
  ///
  /// In fr, this message translates to:
  /// **'Nous sommes au courant de la situation. Nous faisons notre possible pour la régler dans les plus courts délais.'**
  String get service_outage_contact;

  /// No description provided for @service_outage_refresh.
  ///
  /// In fr, this message translates to:
  /// **'Rafraichir'**
  String get service_outage_refresh;

  /// No description provided for @progress_bar_title.
  ///
  /// In fr, this message translates to:
  /// **'Progression de la session'**
  String get progress_bar_title;

  /// No description provided for @progress_bar_message.
  ///
  /// In fr, this message translates to:
  /// **'{elapsedDays} jours écoulés / {totalDays} jours'**
  String progress_bar_message(int elapsedDays, int totalDays);

  /// No description provided for @progress_bar_message_percentage.
  ///
  /// In fr, this message translates to:
  /// **'{percentage} %'**
  String progress_bar_message_percentage(int percentage);

  /// No description provided for @progress_bar_message_remaining_days.
  ///
  /// In fr, this message translates to:
  /// **'{remainingDays} jours restants'**
  String progress_bar_message_remaining_days(int remainingDays);

  /// No description provided for @progress_bar_suffix.
  ///
  /// In fr, this message translates to:
  /// **'jours'**
  String get progress_bar_suffix;

  /// No description provided for @in_app_review_title.
  ///
  /// In fr, this message translates to:
  /// **'Évaluez-nous!'**
  String get in_app_review_title;

  /// No description provided for @need_help.
  ///
  /// In fr, this message translates to:
  /// **'Besoin d\'aide?'**
  String get need_help;

  /// No description provided for @privacy_policy.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get privacy_policy;

  /// No description provided for @universal_code_example.
  ///
  /// In fr, this message translates to:
  /// **'Ex: AB12345'**
  String get universal_code_example;

  /// No description provided for @my_tickets.
  ///
  /// In fr, this message translates to:
  /// **'Mes billets'**
  String get my_tickets;

  /// No description provided for @no_ticket.
  ///
  /// In fr, this message translates to:
  /// **'Aucun billet'**
  String get no_ticket;

  /// No description provided for @ticket_status_open.
  ///
  /// In fr, this message translates to:
  /// **'Ouvert'**
  String get ticket_status_open;

  /// No description provided for @ticket_status_closed.
  ///
  /// In fr, this message translates to:
  /// **'Fermé'**
  String get ticket_status_closed;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get loading;

  /// No description provided for @no_schedule_available.
  ///
  /// In fr, this message translates to:
  /// **'Il n\'y a aucun événement à l\'horaire pour l\'instant'**
  String get no_schedule_available;

  /// No description provided for @social_links_name.
  ///
  /// In fr, this message translates to:
  /// **'Lien social : {linkName}'**
  String social_links_name(String linkName);
}

class _AppIntlDelegate extends LocalizationsDelegate<AppIntl> {
  const _AppIntlDelegate();

  @override
  Future<AppIntl> load(Locale locale) {
    return SynchronousFuture<AppIntl>(lookupAppIntl(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppIntlDelegate old) => false;
}

AppIntl lookupAppIntl(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppIntlEn();
    case 'fr':
      return AppIntlFr();
  }

  throw FlutterError('AppIntl.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
