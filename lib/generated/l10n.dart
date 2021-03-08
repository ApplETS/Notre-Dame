// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values

class AppIntl {
  AppIntl();
  
  static AppIntl current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<AppIntl> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      AppIntl.current = AppIntl();
      
      return AppIntl.current;
    });
  } 

  static AppIntl of(BuildContext context) {
    return Localizations.of<AppIntl>(context, AppIntl);
  }

  /// `An error has occurred`
  String get error {
    return Intl.message(
      'An error has occurred',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `No internet connection`
  String get error_no_internet_connection {
    return Intl.message(
      'No internet connection',
      name: 'error_no_internet_connection',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message(
      'Retry',
      name: 'retry',
      desc: '',
      args: [],
    );
  }

  /// `N/A`
  String get abbreviation_not_available {
    return Intl.message(
      'N/A',
      name: 'abbreviation_not_available',
      desc: '',
      args: [],
    );
  }

  /// `Fall`
  String get session_fall {
    return Intl.message(
      'Fall',
      name: 'session_fall',
      desc: '',
      args: [],
    );
  }

  /// `Winter`
  String get session_winter {
    return Intl.message(
      'Winter',
      name: 'session_winter',
      desc: '',
      args: [],
    );
  }

  /// `Summer`
  String get session_summer {
    return Intl.message(
      'Summer',
      name: 'session_summer',
      desc: '',
      args: [],
    );
  }

  /// `Without Session`
  String get session_without {
    return Intl.message(
      'Without Session',
      name: 'session_without',
      desc: '',
      args: [],
    );
  }

  /// `Open source licenses`
  String get oss_license_title {
    return Intl.message(
      'Open source licenses',
      name: 'oss_license_title',
      desc: '',
      args: [],
    );
  }

  /// `Facebook`
  String get facebook {
    return Intl.message(
      'Facebook',
      name: 'facebook',
      desc: '',
      args: [],
    );
  }

  /// `GitHub`
  String get github {
    return Intl.message(
      'GitHub',
      name: 'github',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Schedule`
  String get title_schedule {
    return Intl.message(
      'Schedule',
      name: 'title_schedule',
      desc: '',
      args: [],
    );
  }

  /// `Student`
  String get title_student {
    return Intl.message(
      'Student',
      name: 'title_student',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard`
  String get title_dashboard {
    return Intl.message(
      'Dashboard',
      name: 'title_dashboard',
      desc: '',
      args: [],
    );
  }

  /// `ÉTS`
  String get title_ets {
    return Intl.message(
      'ÉTS',
      name: 'title_ets',
      desc: '',
      args: [],
    );
  }

  /// `More`
  String get title_more {
    return Intl.message(
      'More',
      name: 'title_more',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login_title {
    return Intl.message(
      'Login',
      name: 'login_title',
      desc: '',
      args: [],
    );
  }

  /// `Universal Code`
  String get login_prompt_universal_code {
    return Intl.message(
      'Universal Code',
      name: 'login_prompt_universal_code',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get login_prompt_password {
    return Intl.message(
      'Password',
      name: 'login_prompt_password',
      desc: '',
      args: [],
    );
  }

  /// `Sign in`
  String get login_action_sign_in {
    return Intl.message(
      'Sign in',
      name: 'login_action_sign_in',
      desc: '',
      args: [],
    );
  }

  /// `This universal code is invalid`
  String get login_error_invalid_universal_code {
    return Intl.message(
      'This universal code is invalid',
      name: 'login_error_invalid_universal_code',
      desc: '',
      args: [],
    );
  }

  /// `This password is incorrect`
  String get login_error_invalid_password {
    return Intl.message(
      'This password is incorrect',
      name: 'login_error_invalid_password',
      desc: '',
      args: [],
    );
  }

  /// `This password is incorrect`
  String get login_error_incorrect_password {
    return Intl.message(
      'This password is incorrect',
      name: 'login_error_incorrect_password',
      desc: '',
      args: [],
    );
  }

  /// `This field is required`
  String get login_error_field_required {
    return Intl.message(
      'This field is required',
      name: 'login_error_field_required',
      desc: '',
      args: [],
    );
  }

  /// `The format of your universal code is AB12345. It was sent to you by the Bureau du registraire upon your admission.`
  String get login_info_universal_code {
    return Intl.message(
      'The format of your universal code is AB12345. It was sent to you by the Bureau du registraire upon your admission.',
      name: 'login_info_universal_code',
      desc: '',
      args: [],
    );
  }

  /// `You have logged out`
  String get login_msg_logout_success {
    return Intl.message(
      'You have logged out',
      name: 'login_msg_logout_success',
      desc: '',
      args: [],
    );
  }

  /// `Made by`
  String get login_applets_logo {
    return Intl.message(
      'Made by',
      name: 'login_applets_logo',
      desc: '',
      args: [],
    );
  }

  /// `Forgot your password?`
  String get login_password_forgotten {
    return Intl.message(
      'Forgot your password?',
      name: 'login_password_forgotten',
      desc: '',
      args: [],
    );
  }

  /// `Card removed`
  String get dashboard_msg_card_removed {
    return Intl.message(
      'Card removed',
      name: 'dashboard_msg_card_removed',
      desc: '',
      args: [],
    );
  }

  /// `Restore all cards`
  String get dashboard_restore_all_cards_title {
    return Intl.message(
      'Restore all cards',
      name: 'dashboard_restore_all_cards_title',
      desc: '',
      args: [],
    );
  }

  /// `No class scheduled today`
  String get card_schedule_no_seances_today {
    return Intl.message(
      'No class scheduled today',
      name: 'card_schedule_no_seances_today',
      desc: '',
      args: [],
    );
  }

  /// `ApplETS`
  String get card_applets_title {
    return Intl.message(
      'ApplETS',
      name: 'card_applets_title',
      desc: '',
      args: [],
    );
  }

  /// `ÉTSMobile was made by the club ApplETS. Support us by liking our Facebook page, contributing to GitHub or sending us your comments via email.`
  String get card_applets_text {
    return Intl.message(
      'ÉTSMobile was made by the club ApplETS. Support us by liking our Facebook page, contributing to GitHub or sending us your comments via email.',
      name: 'card_applets_text',
      desc: '',
      args: [],
    );
  }

  /// `No email application available`
  String get error_no_email_app {
    return Intl.message(
      'No email application available',
      name: 'error_no_email_app',
      desc: '',
      args: [],
    );
  }

  /// `Schedule Settings`
  String get schedule_settings_title {
    return Intl.message(
      'Schedule Settings',
      name: 'schedule_settings_title',
      desc: '',
      args: [],
    );
  }

  /// `Show Today button`
  String get schedule_settings_show_today_btn_pref {
    return Intl.message(
      'Show Today button',
      name: 'schedule_settings_show_today_btn_pref',
      desc: '',
      args: [],
    );
  }

  /// `Calendar format`
  String get schedule_settings_calendar_format_pref {
    return Intl.message(
      'Calendar format',
      name: 'schedule_settings_calendar_format_pref',
      desc: '',
      args: [],
    );
  }

  /// `Month`
  String get schedule_settings_calendar_format_month {
    return Intl.message(
      'Month',
      name: 'schedule_settings_calendar_format_month',
      desc: '',
      args: [],
    );
  }

  /// `2 weeks`
  String get schedule_settings_calendar_format_2_weeks {
    return Intl.message(
      '2 weeks',
      name: 'schedule_settings_calendar_format_2_weeks',
      desc: '',
      args: [],
    );
  }

  /// `Week`
  String get schedule_settings_calendar_format_week {
    return Intl.message(
      'Week',
      name: 'schedule_settings_calendar_format_week',
      desc: '',
      args: [],
    );
  }

  /// `First day of the week`
  String get schedule_settings_starting_weekday_pref {
    return Intl.message(
      'First day of the week',
      name: 'schedule_settings_starting_weekday_pref',
      desc: '',
      args: [],
    );
  }

  /// `No events scheduled.`
  String get schedule_no_event {
    return Intl.message(
      'No events scheduled.',
      name: 'schedule_no_event',
      desc: '',
      args: [],
    );
  }

  /// `Monday`
  String get schedule_settings_starting_weekday_monday {
    return Intl.message(
      'Monday',
      name: 'schedule_settings_starting_weekday_monday',
      desc: '',
      args: [],
    );
  }

  /// `Tuesday`
  String get schedule_settings_starting_weekday_tuesday {
    return Intl.message(
      'Tuesday',
      name: 'schedule_settings_starting_weekday_tuesday',
      desc: '',
      args: [],
    );
  }

  /// `Wednesday`
  String get schedule_settings_starting_weekday_wednesday {
    return Intl.message(
      'Wednesday',
      name: 'schedule_settings_starting_weekday_wednesday',
      desc: '',
      args: [],
    );
  }

  /// `Thursday`
  String get schedule_settings_starting_weekday_thursday {
    return Intl.message(
      'Thursday',
      name: 'schedule_settings_starting_weekday_thursday',
      desc: '',
      args: [],
    );
  }

  /// `Friday`
  String get schedule_settings_starting_weekday_friday {
    return Intl.message(
      'Friday',
      name: 'schedule_settings_starting_weekday_friday',
      desc: '',
      args: [],
    );
  }

  /// `Saturday`
  String get schedule_settings_starting_weekday_saturday {
    return Intl.message(
      'Saturday',
      name: 'schedule_settings_starting_weekday_saturday',
      desc: '',
      args: [],
    );
  }

  /// `Sunday`
  String get schedule_settings_starting_weekday_sunday {
    return Intl.message(
      'Sunday',
      name: 'schedule_settings_starting_weekday_sunday',
      desc: '',
      args: [],
    );
  }

  /// `No event found`
  String get schedule_error_no_event_found {
    return Intl.message(
      'No event found',
      name: 'schedule_error_no_event_found',
      desc: '',
      args: [],
    );
  }

  /// `Grades`
  String get grades_title {
    return Intl.message(
      'Grades',
      name: 'grades_title',
      desc: '',
      args: [],
    );
  }

  /// `No grade available`
  String get grades_msg_no_grades {
    return Intl.message(
      'No grade available',
      name: 'grades_msg_no_grades',
      desc: '',
      args: [],
    );
  }

  /// `Your grade`
  String get grades_current_rating {
    return Intl.message(
      'Your grade',
      name: 'grades_current_rating',
      desc: '',
      args: [],
    );
  }

  /// `Average`
  String get grades_average {
    return Intl.message(
      'Average',
      name: 'grades_average',
      desc: '',
      args: [],
    );
  }

  /// `{grade}%`
  String grades_grade_in_percentage(Object grade) {
    return Intl.message(
      '$grade%',
      name: 'grades_grade_in_percentage',
      desc: '',
      args: [grade],
    );
  }

  /// `{grade}/{maxGrade} ({inPercentage}%)`
  String grades_grade_with_percentage(Object grade, Object maxGrade, Object inPercentage) {
    return Intl.message(
      '$grade/$maxGrade ($inPercentage%)',
      name: 'grades_grade_with_percentage',
      desc: '',
      args: [grade, maxGrade, inPercentage],
    );
  }

  /// `Weight: {weight}%`
  String grades_weight(Object weight) {
    return Intl.message(
      'Weight: $weight%',
      name: 'grades_weight',
      desc: '',
      args: [weight],
    );
  }

  /// `Group`
  String get grades_group {
    return Intl.message(
      'Group',
      name: 'grades_group',
      desc: '',
      args: [],
    );
  }

  /// `Grade`
  String get grades_grade {
    return Intl.message(
      'Grade',
      name: 'grades_grade',
      desc: '',
      args: [],
    );
  }

  /// `Median`
  String get grades_median {
    return Intl.message(
      'Median',
      name: 'grades_median',
      desc: '',
      args: [],
    );
  }

  /// `Standard Deviation`
  String get grades_standard_deviation {
    return Intl.message(
      'Standard Deviation',
      name: 'grades_standard_deviation',
      desc: '',
      args: [],
    );
  }

  /// `Percentile Rank`
  String get grades_percentile_rank {
    return Intl.message(
      'Percentile Rank',
      name: 'grades_percentile_rank',
      desc: '',
      args: [],
    );
  }

  /// `Target Date`
  String get grades_target_date {
    return Intl.message(
      'Target Date',
      name: 'grades_target_date',
      desc: '',
      args: [],
    );
  }

  /// `Ignored evaluation`
  String get grades_ignored_evaluation_title {
    return Intl.message(
      'Ignored evaluation',
      name: 'grades_ignored_evaluation_title',
      desc: '',
      args: [],
    );
  }

  /// `This evaluation is ignored in the calculation of the final grade. This situation occurs when the teacher has decided to keep, for example, the top three marks of the six assignments he has asked for. The three lowest grades would then be ignored.`
  String get grades_ignored_evaluation_details {
    return Intl.message(
      'This evaluation is ignored in the calculation of the final grade. This situation occurs when the teacher has decided to keep, for example, the top three marks of the six assignments he has asked for. The three lowest grades would then be ignored.',
      name: 'grades_ignored_evaluation_details',
      desc: '',
      args: [],
    );
  }

  /// `Failed to retrieve data for this course`
  String get grades_error_failed_to_retrieve_data_course {
    return Intl.message(
      'Failed to retrieve data for this course',
      name: 'grades_error_failed_to_retrieve_data_course',
      desc: '',
      args: [],
    );
  }

  /// `Summary`
  String get grades_summary_section_title {
    return Intl.message(
      'Summary',
      name: 'grades_summary_section_title',
      desc: '',
      args: [],
    );
  }

  /// `Evaluations`
  String get grades_evaluations_section_title {
    return Intl.message(
      'Evaluations',
      name: 'grades_evaluations_section_title',
      desc: '',
      args: [],
    );
  }

  /// `Group {number}`
  String grades_group_number(Object number) {
    return Intl.message(
      'Group $number',
      name: 'grades_group_number',
      desc: '',
      args: [number],
    );
  }

  /// `During the evaluation period, you will not be able access your grades if you haven't completed your evaluations.`
  String get grades_error_course_evaluations_not_completed {
    return Intl.message(
      'During the evaluation period, you will not be able access your grades if you haven\'t completed your evaluations.',
      name: 'grades_error_course_evaluations_not_completed',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile_title {
    return Intl.message(
      'Profile',
      name: 'profile_title',
      desc: '',
      args: [],
    );
  }

  /// `Student Status`
  String get profile_student_status_title {
    return Intl.message(
      'Student Status',
      name: 'profile_student_status_title',
      desc: '',
      args: [],
    );
  }

  /// `Personal Information`
  String get profile_personal_information_title {
    return Intl.message(
      'Personal Information',
      name: 'profile_personal_information_title',
      desc: '',
      args: [],
    );
  }

  /// `First Name`
  String get profile_first_name {
    return Intl.message(
      'First Name',
      name: 'profile_first_name',
      desc: '',
      args: [],
    );
  }

  /// `Last Name`
  String get profile_last_name {
    return Intl.message(
      'Last Name',
      name: 'profile_last_name',
      desc: '',
      args: [],
    );
  }

  /// `Permanent Code`
  String get profile_permanent_code {
    return Intl.message(
      'Permanent Code',
      name: 'profile_permanent_code',
      desc: '',
      args: [],
    );
  }

  /// `Balance`
  String get profile_balance {
    return Intl.message(
      'Balance',
      name: 'profile_balance',
      desc: '',
      args: [],
    );
  }

  /// `Code`
  String get profile_code_program {
    return Intl.message(
      'Code',
      name: 'profile_code_program',
      desc: '',
      args: [],
    );
  }

  /// `Average`
  String get profile_average_program {
    return Intl.message(
      'Average',
      name: 'profile_average_program',
      desc: '',
      args: [],
    );
  }

  /// `Accumulated Credits`
  String get profile_number_accumulated_credits_program {
    return Intl.message(
      'Accumulated Credits',
      name: 'profile_number_accumulated_credits_program',
      desc: '',
      args: [],
    );
  }

  /// `Registered Credits`
  String get profile_number_registered_credits_program {
    return Intl.message(
      'Registered Credits',
      name: 'profile_number_registered_credits_program',
      desc: '',
      args: [],
    );
  }

  /// `Completed Courses`
  String get profile_number_completed_courses_program {
    return Intl.message(
      'Completed Courses',
      name: 'profile_number_completed_courses_program',
      desc: '',
      args: [],
    );
  }

  /// `Failed Courses`
  String get profile_number_failed_courses_program {
    return Intl.message(
      'Failed Courses',
      name: 'profile_number_failed_courses_program',
      desc: '',
      args: [],
    );
  }

  /// `Equivalent Courses`
  String get profile_number_equivalent_courses_program {
    return Intl.message(
      'Equivalent Courses',
      name: 'profile_number_equivalent_courses_program',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get profile_status_program {
    return Intl.message(
      'Status',
      name: 'profile_status_program',
      desc: '',
      args: [],
    );
  }

  /// `Security`
  String get ets_security_title {
    return Intl.message(
      'Security',
      name: 'ets_security_title',
      desc: '',
      args: [],
    );
  }

  /// `MonÉTS`
  String get ets_monets_title {
    return Intl.message(
      'MonÉTS',
      name: 'ets_monets_title',
      desc: '',
      args: [],
    );
  }

  /// `Bibliotech`
  String get ets_bibliotech_title {
    return Intl.message(
      'Bibliotech',
      name: 'ets_bibliotech_title',
      desc: '',
      args: [],
    );
  }

  /// `News`
  String get ets_news_title {
    return Intl.message(
      'News',
      name: 'ets_news_title',
      desc: '',
      args: [],
    );
  }

  /// `Moodle`
  String get ets_moodle_title {
    return Intl.message(
      'Moodle',
      name: 'ets_moodle_title',
      desc: '',
      args: [],
    );
  }

  /// `Directory`
  String get ets_directory_title {
    return Intl.message(
      'Directory',
      name: 'ets_directory_title',
      desc: '',
      args: [],
    );
  }

  /// `L'heuristique`
  String get ets_heuristique_title {
    return Intl.message(
      'L\'heuristique',
      name: 'ets_heuristique_title',
      desc: '',
      args: [],
    );
  }

  /// `About ApplETS`
  String get more_about_applets_title {
    return Intl.message(
      'About ApplETS',
      name: 'more_about_applets_title',
      desc: '',
      args: [],
    );
  }

  /// `Report a bug`
  String get more_report_bug {
    return Intl.message(
      'Report a bug',
      name: 'more_report_bug',
      desc: '',
      args: [],
    );
  }

  /// `How would you like to report the bug?`
  String get more_prompt_report_bug_method {
    return Intl.message(
      'How would you like to report the bug?',
      name: 'more_prompt_report_bug_method',
      desc: '',
      args: [],
    );
  }

  /// `Screenshot`
  String get more_report_bug_method_screenshot {
    return Intl.message(
      'Screenshot',
      name: 'more_report_bug_method_screenshot',
      desc: '',
      args: [],
    );
  }

  /// `Video recording`
  String get more_report_bug_method_video {
    return Intl.message(
      'Video recording',
      name: 'more_report_bug_method_video',
      desc: '',
      args: [],
    );
  }

  /// `Contributors`
  String get more_contributors {
    return Intl.message(
      'Contributors',
      name: 'more_contributors',
      desc: '',
      args: [],
    );
  }

  /// `Open source licenses`
  String get more_open_source_licenses {
    return Intl.message(
      'Open source licenses',
      name: 'more_open_source_licenses',
      desc: '',
      args: [],
    );
  }

  /// `Beta FAQ`
  String get more_beta_faq {
    return Intl.message(
      'Beta FAQ',
      name: 'more_beta_faq',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get more_settings {
    return Intl.message(
      'Settings',
      name: 'more_settings',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get more_log_out {
    return Intl.message(
      'Log out',
      name: 'more_log_out',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to log out?`
  String get more_prompt_log_out_confirmation {
    return Intl.message(
      'Are you sure you want to log out?',
      name: 'more_prompt_log_out_confirmation',
      desc: '',
      args: [],
    );
  }

  /// `Disconnection in progress`
  String get more_log_out_progress {
    return Intl.message(
      'Disconnection in progress',
      name: 'more_log_out_progress',
      desc: '',
      args: [],
    );
  }

  /// `ÉTSMobile was conceived by the ApplETS scientific club from the École de technologie supérieure.\n\nApplets is, most importantly, a gathering of students who share a typical enthusiasm for the field of telecommunications and mobile applications. The mission of ApplETS is to train students in mobile development and promote the production of mobile applications within the student community.\n\nFollow us on: `
  String get more_applets_about_details {
    return Intl.message(
      'ÉTSMobile was conceived by the ApplETS scientific club from the École de technologie supérieure.\n\nApplets is, most importantly, a gathering of students who share a typical enthusiasm for the field of telecommunications and mobile applications. The mission of ApplETS is to train students in mobile development and promote the production of mobile applications within the student community.\n\nFollow us on: ',
      name: 'more_applets_about_details',
      desc: '',
      args: [],
    );
  }

  /// `Bomb threat`
  String get security_bomb_threat_title {
    return Intl.message(
      'Bomb threat',
      name: 'security_bomb_threat_title',
      desc: '',
      args: [],
    );
  }

  /// `bomb_threat_detail_en.html`
  String get security_bomb_threat_detail {
    return Intl.message(
      'bomb_threat_detail_en.html',
      name: 'security_bomb_threat_detail',
      desc: '',
      args: [],
    );
  }

  /// `Suspicious packages`
  String get security_suspicious_packages_title {
    return Intl.message(
      'Suspicious packages',
      name: 'security_suspicious_packages_title',
      desc: '',
      args: [],
    );
  }

  /// `suspicious_packages_detail_en.html`
  String get security_suspicious_packages_detail {
    return Intl.message(
      'suspicious_packages_detail_en.html',
      name: 'security_suspicious_packages_detail',
      desc: '',
      args: [],
    );
  }

  /// `Evacuation`
  String get security_evacuation_title {
    return Intl.message(
      'Evacuation',
      name: 'security_evacuation_title',
      desc: '',
      args: [],
    );
  }

  /// `evacuation_detail_en.html`
  String get security_evacuation_detail {
    return Intl.message(
      'evacuation_detail_en.html',
      name: 'security_evacuation_detail',
      desc: '',
      args: [],
    );
  }

  /// `Gas leak`
  String get security_gas_leak_title {
    return Intl.message(
      'Gas leak',
      name: 'security_gas_leak_title',
      desc: '',
      args: [],
    );
  }

  /// `gas_leak_detail_en.html`
  String get security_gas_leak_detail {
    return Intl.message(
      'gas_leak_detail_en.html',
      name: 'security_gas_leak_detail',
      desc: '',
      args: [],
    );
  }

  /// `Fire`
  String get security_fire_title {
    return Intl.message(
      'Fire',
      name: 'security_fire_title',
      desc: '',
      args: [],
    );
  }

  /// `fire_detail_en.html`
  String get security_fire_detail {
    return Intl.message(
      'fire_detail_en.html',
      name: 'security_fire_detail',
      desc: '',
      args: [],
    );
  }

  /// `Broken elevator`
  String get security_broken_elevator_title {
    return Intl.message(
      'Broken elevator',
      name: 'security_broken_elevator_title',
      desc: '',
      args: [],
    );
  }

  /// `broken_elevator_detail_en.html`
  String get security_broken_elevator_detail {
    return Intl.message(
      'broken_elevator_detail_en.html',
      name: 'security_broken_elevator_detail',
      desc: '',
      args: [],
    );
  }

  /// `Electrical outage`
  String get security_electrical_outage_title {
    return Intl.message(
      'Electrical outage',
      name: 'security_electrical_outage_title',
      desc: '',
      args: [],
    );
  }

  /// `electrical_outage_detail_en.html`
  String get security_electrical_outage_detail {
    return Intl.message(
      'electrical_outage_detail_en.html',
      name: 'security_electrical_outage_detail',
      desc: '',
      args: [],
    );
  }

  /// `Armed person`
  String get security_armed_person_title {
    return Intl.message(
      'Armed person',
      name: 'security_armed_person_title',
      desc: '',
      args: [],
    );
  }

  /// `armed_person_detail_en.html`
  String get security_armed_person_detail {
    return Intl.message(
      'armed_person_detail_en.html',
      name: 'security_armed_person_detail',
      desc: '',
      args: [],
    );
  }

  /// `Earthquake`
  String get security_earthquake_title {
    return Intl.message(
      'Earthquake',
      name: 'security_earthquake_title',
      desc: '',
      args: [],
    );
  }

  /// `earthquake_detail_en.html`
  String get security_earthquake_detail {
    return Intl.message(
      'earthquake_detail_en.html',
      name: 'security_earthquake_detail',
      desc: '',
      args: [],
    );
  }

  /// `Medical emergency`
  String get security_medical_emergency_title {
    return Intl.message(
      'Medical emergency',
      name: 'security_medical_emergency_title',
      desc: '',
      args: [],
    );
  }

  /// `medical_emergency_detail_en.html`
  String get security_medical_emergency_detail {
    return Intl.message(
      'medical_emergency_detail_en.html',
      name: 'security_medical_emergency_detail',
      desc: '',
      args: [],
    );
  }

  /// `Emergency call`
  String get security_emergency_call {
    return Intl.message(
      'Emergency call',
      name: 'security_emergency_call',
      desc: '',
      args: [],
    );
  }

  /// `Reach security`
  String get security_reach_security {
    return Intl.message(
      'Reach security',
      name: 'security_reach_security',
      desc: '',
      args: [],
    );
  }

  /// `514 396–8900`
  String get security_emergency_number {
    return Intl.message(
      '514 396–8900',
      name: 'security_emergency_number',
      desc: '',
      args: [],
    );
  }

  /// `From inside campus`
  String get security_emergency_intern_call {
    return Intl.message(
      'From inside campus',
      name: 'security_emergency_intern_call',
      desc: '',
      args: [],
    );
  }

  /// `Ex. 55`
  String get security_emergency_intern_number {
    return Intl.message(
      'Ex. 55',
      name: 'security_emergency_intern_number',
      desc: '',
      args: [],
    );
  }

  /// `Emergency procedures`
  String get security_emergency_procedures {
    return Intl.message(
      'Emergency procedures',
      name: 'security_emergency_procedures',
      desc: '',
      args: [],
    );
  }

  /// `Security station`
  String get security_station {
    return Intl.message(
      'Security station',
      name: 'security_station',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings_title {
    return Intl.message(
      'Settings',
      name: 'settings_title',
      desc: '',
      args: [],
    );
  }

  /// `Display`
  String get settings_display_pref_category {
    return Intl.message(
      'Display',
      name: 'settings_display_pref_category',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get settings_dark_theme_pref {
    return Intl.message(
      'Theme',
      name: 'settings_dark_theme_pref',
      desc: '',
      args: [],
    );
  }

  /// `Miscellaneous`
  String get settings_miscellaneous_category {
    return Intl.message(
      'Miscellaneous',
      name: 'settings_miscellaneous_category',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get settings_language_pref {
    return Intl.message(
      'Language',
      name: 'settings_language_pref',
      desc: '',
      args: [],
    );
  }

  /// `Français`
  String get settings_french {
    return Intl.message(
      'Français',
      name: 'settings_french',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get settings_english {
    return Intl.message(
      'English',
      name: 'settings_english',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get dark_theme {
    return Intl.message(
      'Dark',
      name: 'dark_theme',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get light_theme {
    return Intl.message(
      'Light',
      name: 'light_theme',
      desc: '',
      args: [],
    );
  }

  /// `System`
  String get system_theme {
    return Intl.message(
      'System',
      name: 'system_theme',
      desc: '',
      args: [],
    );
  }

  /// `Thank you for the feedback`
  String get thank_you_for_the_feedback {
    return Intl.message(
      'Thank you for the feedback',
      name: 'thank_you_for_the_feedback',
      desc: '',
      args: [],
    );
  }

  /// `Flutter is Google's UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase. Learn more about Flutter at `
  String get flutter_license {
    return Intl.message(
      'Flutter is Google\'s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase. Learn more about Flutter at ',
      name: 'flutter_license',
      desc: '',
      args: [],
    );
  }

  /// `https://flutter.dev`
  String get flutter_website {
    return Intl.message(
      'https://flutter.dev',
      name: 'flutter_website',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppIntl> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'fr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<AppIntl> load(Locale locale) => AppIntl.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}