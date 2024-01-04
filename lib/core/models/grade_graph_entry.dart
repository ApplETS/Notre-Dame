// Package imports:
import 'package:ets_api_clients/models.dart';
import 'package:intl/intl.dart';

class GradeGraphEntry {
  DateTime timestamp;
  String acronym;
  String group;
  String session;
  CourseSummary summary;

  GradeGraphEntry(this.acronym, this.group, this.session, this.summary) {
    final DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    final DateTime now = DateTime.parse(dateFormat.format(DateTime.now()));
    timestamp = now;
  }

  GradeGraphEntry.withTimeStamp(
      {this.timestamp, this.acronym, this.group, this.session, this.summary});

  factory GradeGraphEntry.fromJson(Map<String, dynamic> json) =>
      GradeGraphEntry.withTimeStamp(
        timestamp: DateFormat("yyyy-MM-dd HH:mm:ss")
            .parse(json['timestamp'].toString()),
        acronym: json["acronym"].toString(),
        group: json["group"].toString(),
        session: json["session"].toString(),
        summary:
            CourseSummary.fromJson(json["summary"] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toString(),
      'acronym': acronym,
      'group': group,
      'session': session,
      'summary': summary.toJson(),
    };
  }
}
