// Project imports:
import 'package:notredame/data/services/signets-api/models/replaced_day.dart';
import 'package:notredame/utils/utils.dart';

/// Analyzes replaced days to find upcoming schedule changes.
class ReplacedDayAnalyzer {
  final List<ReplacedDay> replacedDays;
  final DateTime now;

  ReplacedDayAnalyzer({required this.replacedDays, required this.now});

  ReplacedDay? getUpcoming() {
    if (replacedDays.isEmpty) return null;

    final today = Utils.dateOnly(now);
    final sevenDaysFromNow = today.add(const Duration(days: 7));

    final upcoming = replacedDays.where((replacedDay) {
      final originalDate = Utils.dateOnly(replacedDay.originalDate);
      return !originalDate.isBefore(today) && originalDate.isBefore(sevenDaysFromNow);
    }).toList();

    if (upcoming.isEmpty) return null;

    upcoming.sort((a, b) => Utils.dateOnly(a.originalDate).compareTo(Utils.dateOnly(b.originalDate)));

    return upcoming.first;
  }

  bool isCancellation(ReplacedDay replacedDay) {
    return replacedDay.replacementDate.isBefore(replacedDay.originalDate);
  }
}
