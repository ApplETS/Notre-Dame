import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';

abstract class CustomFeedbackLocalizations implements FeedbackLocalizations {
  String get email;
}

class FrFeedbackLocalizations implements CustomFeedbackLocalizations {
  @override
  String get draw => "Dessiner";

  @override
  String get feedbackDescriptionText => "Description";

  @override
  String get navigate => "Naviguer";

  @override
  String get submitButtonText => "Envoyer";

  @override
  String get email => "Courriel (facultatif)";
}

class EnFeedbackLocalizations implements CustomFeedbackLocalizations {
  @override
  String get draw => "Draw";

  @override
  String get feedbackDescriptionText => "Description";

  @override
  String get navigate => "Navigate";

  @override
  String get submitButtonText => "Submit";

  @override
  String get email => "Email (Optional)";
}

class CustomFeedbackLocalizationsDelegate
    extends GlobalFeedbackLocalizationsDelegate {
  @override
  // ignore: overridden_fields
  final supportedLocales = <Locale, FeedbackLocalizations>{
    const Locale('en'): EnFeedbackLocalizations(),
    const Locale('fr'): FrFeedbackLocalizations(),
  };
}
