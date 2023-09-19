// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

// MODELS
import 'package:notredame/core/models/faq_actions.dart';
import 'package:notredame/core/models/faq_questions.dart';

class Faq {
  List<QuestionItem> questions = [
    QuestionItem(
      title: {
        "fr": "Quel mot de passe dois-je utiliser pour me connecter ?",
        "en": "What password should I use to log in?"
      },
      description: {
        "fr": "Le mot de passe à utiliser correspond à celui utilisé pour la connexion à MonÉTS et les autres systèmes informatiques de l’ÉTS.",
        "en": "The password is the one you use for logging into MonÉTS and other ÉTS computer systems."
      },
    ),
    QuestionItem(
      title: {
        "fr": "Je n’ai pas accès au cours et au programme.",
        "en": "I don't have access to the courses and program."
      },
      description: {
        "fr": "Les nouveaux étudiants pourraient ne pas voir l’horaire et les cours inscrits avant le début de la première session de cours. Cependant, ces informations apparaissent dès le début de la première session de cours.",
        "en": "New students may not see the schedule and courses before the start of the first course session. However, this information becomes available at the beginning of the first course session."
      },
    ),
    QuestionItem(
      title: {
        "fr": "Je suis diplômé de l’ÉTS et je souhaite faire réactiver mon compte.",
        "en": "I am an ÉTS graduate, and I want to reactivate my account."
      },
      description: {
        "fr": "Vous pouvez demander de réactiver votre compte",
        "en": "You can request to reactivate your account."
      },
    ),
    QuestionItem(
      title: {
        "fr": "Je ne vois plus mes notes de contrôle",
        "en": "I can't see my control grades anymore."
      },
      description: {
        "fr": "Il est possible qu’il s’agit de la période d'évaluation des cours. Vous devez compléter les évaluations sur SignETS. Les notes seront disponibles après avoir répondu aux évaluations.",
        "en": "It is possible that this is the course evaluation period. You need to complete the evaluations on SignETS. Grades will be available after responding to the evaluations."
      },
    ),
  ];

  List<ActionItem> actions = [
    ActionItem(
      title: {
        "fr": "Où trouver mon code universel ?",
        "en": "Where can I find my universal code?"
      },
      description: {
        "fr": "Il se trouve dans la décision d’admission sur le portail de monÉTS.",
        "en": "It can be found in the admission decision on the MonÉTS portal."
      },
      type: ActionType.webview,
      link: "https://portail.etsmtl.ca/home/Admission",
      iconName: "icon_universal_code",
      iconColor: const Color.fromRGBO(63, 219, 251, 1),
      circleColor: const Color.fromRGBO(14, 127, 188, 1),
    ),
    ActionItem(
      title: {
        "fr": "Je suis diplômé de l’ÉTS et je souhaite faire réactiver mon compte.",
        "en": "I am an ÉTS graduate, and I want to reactivate my account."
      },
      description: {
        "fr": "Vous pouvez demander de réactiver votre compte.",
        "en": "You can request to reactivate your account."
      },
      type: ActionType.webview,
      link: "https://formulaires.etsmtl.ca/ReactivationCompte",
      iconName: "icon_reactivate_account",
      iconColor: const Color.fromRGBO(63, 219, 251, 1),
      circleColor: const Color.fromRGBO(14, 127, 188, 1),
    ),
    ActionItem(
      title: {
        "fr": "Questions concernant vos conditions d'admission, des inscriptions et des conditions relatives à la poursuite de vos études",
        "en": "Questions about your admission conditions, registrations, and conditions for continuing your studies"
      },
      description: {
        "fr": "Veuillez contacter le Bureau de la registraire",
        "en": "Please contact the Office of the Registrar"
      },
      type: ActionType.email,
      link: "accueilbdr@etsmtl.ca",
      iconName: "icon_contact_registrar",
      iconColor: const Color.fromRGBO(63, 219, 251, 1),
      circleColor: const Color.fromRGBO(14, 127, 188, 1),
    ),
    ActionItem(
      title: {
        "fr": "Questions concernant l’application ÉTSMobile",
        "en": "Questions about the ÉTSMobile app"
      },
      description: {
        "fr": "Veuillez contacter App|ETS.",
        "en": "Please contact App|ETS."
      },
      type: ActionType.email,
      link: "AppInfo.email",
      iconName: "icon_contact_app_ets",
      iconColor: const Color.fromRGBO(63, 219, 251, 1),
      circleColor: const Color.fromRGBO(14, 127, 188, 1),
    ),
  ];
}
