import 'package:notredame/ui/dashboard/services/session_context.dart';

class MessageFlowEngine {
  String? determineMessage(SessionContext context) {
    if (!context.isSessionStarted) {
      return "Repose-toi bien! La session recommence le ${context.session.startDate}";
    }

    if (context.daysRemaining <= 7) {
      return "Encore ${context.daysRemaining} jours et c'est fini !";
    }

    if (context.isLongWeekend) {
      return "Une longue fin de semaine s'en vient!";
    }

    // if is holiday coming
    //return "Jour férié mardi!";

    if (context.monthsCompleted <= 1) {
      if (context.weeksCompleted < 1) {
        return "Bon début de session!";
      }

      if (context.daysSinceStart % 7 == 0) {
        if (context.weeksCompleted == 1) {
          return "Première semaine de la session complétée, continue!";
        }
        return "${context.weeksCompleted} ieme semaine complétée!";
      }

      return _getGenericEncouragement();
    }

    if (context.monthsRemaining <= 1) {
      return "Tiens bon, il ne reste que ${context.weeksRemaining} semaines";
    }

    return _getGenericEncouragement();
  }

  String _getGenericEncouragement() {
    return "Message d'encouragement générique";
  }
}
