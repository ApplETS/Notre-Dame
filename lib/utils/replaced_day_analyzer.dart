// Project imports:
import 'package:notredame/data/services/signets-api/models/replaced_day.dart';
import 'package:notredame/utils/date_extensions.dart';

/// Analyzes replaced days to find upcoming schedule changes.
class ReplacedDayAnalyzer {
  final List<ReplacedDay> replacedDays;
  final DateTime now;

  ReplacedDayAnalyzer({required this.replacedDays, required this.now});

  ReplacedDay? getUpcoming() {
    if (replacedDays.isEmpty) return null;

    final today = now.withoutTimeUtc;
    final sevenDaysFromNow = today.add(const Duration(days: 7));

    final upcoming = replacedDays.where((replacedDay) {
      final originalDate = replacedDay.originalDate.withoutTimeUtc;
      return !originalDate.isBefore(today) && originalDate.isBefore(sevenDaysFromNow);
    }).toList();

    if (upcoming.isEmpty) return null;

    upcoming.sort((a, b) => a.originalDate.withoutTimeUtc.compareTo(b.originalDate.withoutTimeUtc));

    return upcoming.first;
  }

  bool isCancellation(ReplacedDay replacedDay) {
    return replacedDay.replacementDate.isBefore(replacedDay.originalDate);
  }
}
