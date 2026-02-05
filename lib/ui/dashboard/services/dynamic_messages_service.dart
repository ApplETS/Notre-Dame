import 'package:notredame/ui/dashboard/services/session_context.dart';

class MessageFlowEngine {
  String? determineMessage(SessionContext context) {
    if (!context.isSessionStarted) {
      return "Repose-toi bien ! La session recommence le 5 septembre !";
    }
    
    if (context.daysRemaining <= 7) {
      return "Encore ${context.daysRemaining} jours et c'est fini !";
    }
    
    if (!context.hasNextWeekSchedule) {
      if (context.isLastDayOfWeek) {
        return "Une longue fin de semaine s'en vient !";
      }
      
      if (!context.isLastDayOfWeek) {
        return "Jour férié mardi !";
      }
    }
    
    if (context.sessionStartedMonthsAgo >= 1) {
      return "Très bon, il ne reste que 2 semaines !";
    }
    
    if (context.sessionStartedMonthsAgo > 1) {
      return _getGenericEncouragement();
    }
    
    return null;
  }
  
  String _getGenericEncouragement() {
    return "Message d'encouragement générique";
  }
}
