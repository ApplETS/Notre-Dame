// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/domain/constants/app_info.dart';
import 'package:notredame/ui/more/faq/models/faq_actions.dart';
import 'package:notredame/ui/more/faq/models/faq_questions.dart';

class Faq {
  List<QuestionItem> questions = [
    QuestionItem(
      title: {
        "fr": "Je n’ai pas accès au cours et au programme.",
        "en": "I don't have access to the courses and program."
      },
      description: {
        "fr":
            "Les nouveaux étudiants pourraient ne pas voir l’horaire et les cours inscrits avant le début de la première session de cours. Cependant, ces informations apparaissent dès le début de la première session de cours.",
        "en":
            "New students may not see the schedule and courses before the start of the first course session. However, this information becomes available at the beginning of the first course session."
      },
    ),
    QuestionItem(
      title: {"fr": "Je ne vois plus mes notes de contrôle", "en": "I can't see my grades anymore."},
      description: {
        "fr":
            "Il est possible qu’il s’agit de la période d'évaluation des cours. Vous devez compléter les évaluations sur SignETS. Les notes seront disponibles après avoir répondu aux évaluations.",
        "en":
            "It is possible that this is the course evaluation period. You need to complete the evaluations on SignETS. Grades will be available after responding to the evaluations."
      },
    ),
  ];

  List<ActionItem> actions = [
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
      iconName: Icons.school,
      iconColor: const Color(0xFF78E2BC),
      circleColor: const Color(0xFF39B78A),
    ),
    ActionItem(
      title: {
        "fr":
            "Questions concernant vos conditions d'admission, des inscriptions et des conditions relatives à la poursuite de vos études",
        "en": "Questions about your admission conditions, registrations, and conditions for continuing your studies"
      },
      description: {
        "fr": "Veuillez contacter le Bureau de la registraire.",
        "en": "Please contact the Office of the Registrar."
      },
      type: ActionType.email,
      link: "accueilbdr@etsmtl.ca",
      iconName: Icons.email,
      iconColor: const Color(0xFFFCA4A4),
      circleColor: const Color(0xFFDA4444),
    ),
    ActionItem(
      title: {"fr": "Questions concernant l’application ÉTSMobile", "en": "Questions about the ÉTSMobile app"},
      description: {"fr": "Veuillez contacter App|ETS.", "en": "Please contact App|ETS."},
      type: ActionType.email,
      link: AppInfo.email,
      iconName: Icons.install_mobile,
      iconColor: const Color(0xFF71D8F7),
      circleColor: const Color(0xFF397DB7),
    ),
  ];
}
