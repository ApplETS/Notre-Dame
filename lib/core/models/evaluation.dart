import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

/// Data-class that represent an evaluation which happened during a course
class Evaluation {
  final String courseGroup;

  /// Title of the evaluation (ex: Laboratoire 1)
  final String title;

  /// Date on which the evaluation should happen (can also be the date on which
  /// the mark was enter in the system)
  /// Can be null!
  final DateTime targetDate;

  /// Mark obtained by the student on the evaluation
  /// (ex: 24)
  final double mark;

  /// On how much the evaluation is corrected (ex: 30)
  final double correctedEvaluationOutOfFormatted;

  /// On how much the evaluation is corrected included bonus (ex: 30,0+20)
  final String correctedEvaluationOutOf;

  /// Weight of the evaluation on the course (ex: 12.5)
  final double weight;

  /// Average mark of the students on this evaluation (ex: 30)
  final double passMark;

  /// Standard deviation of the evaluation
  final double standardDeviation;

  /// Median of the evaluation
  final double median;

  /// Percentile rank of the student on this evaluation
  final int percentileRank;

  /// Is the mark of the evaluation published
  final bool published;

  /// Message given by the teacher
  final String teacherMessage;

  /// Is this evaluation ignored in the final grade
  final bool ignore;

  double get markInPercent => mark / correctedEvaluationOutOfFormatted;

  Evaluation(
      {@required this.courseGroup,
      @required this.title,
      @required this.weight,
      @required this.published,
      @required this.teacherMessage,
      @required this.ignore,
      @required this.correctedEvaluationOutOf,
      this.mark,
      this.passMark,
      this.standardDeviation,
      this.median,
      this.percentileRank,
      this.targetDate})
      : correctedEvaluationOutOfFormatted = correctedEvaluationOutOf.isNotEmpty
            ? double.parse(
                correctedEvaluationOutOf.split("+").first.replaceAll(",", "."))
            : 0.0;

  /// Used to create a new [Evaluation] instance from a [XMLElement].
  factory Evaluation.fromXml(XmlElement node) => Evaluation(
      courseGroup: node.getElement('coursGroupe').innerText,
      title: node.getElement('nom').innerText,
      mark: node.getElement('note').innerText.isNotEmpty
          ? double.parse(node.getElement('note').innerText.replaceAll(",", "."))
          : null,
      correctedEvaluationOutOf:
          node.getElement('corrigeSur').innerText.replaceAll(",", "."),
      weight: double.parse(
          node.getElement('ponderation').innerText.replaceAll(",", ".")),
      passMark: node.getElement('moyenne').innerText.isNotEmpty
          ? double.parse(
              node.getElement('moyenne').innerText.replaceAll(",", "."))
          : null,
      standardDeviation: node.getElement('ecartType').innerText.isNotEmpty
          ? double.parse(
              node.getElement('ecartType').innerText.replaceAll(",", "."))
          : null,
      median: node.getElement('mediane').innerText.isNotEmpty
          ? double.parse(
              node.getElement('mediane').innerText.replaceAll(",", "."))
          : null,
      percentileRank: node.getElement('rangCentile').innerText.isNotEmpty
          ? int.parse(node.getElement('rangCentile').innerText)
          : null,
      published: node.getElement('publie').innerText == "Oui",
      teacherMessage: node.getElement('messageDuProf').innerText,
      ignore: node.getElement('ignoreDuCalcul').innerText == "Oui",
      targetDate: node.getElement('dateCible').innerText.isNotEmpty
          ? DateTime.parse(node.getElement('dateCible').innerText)
          : null);

  /// Used to create [Evaluation] instance from a JSON file
  factory Evaluation.fromJson(Map<String, dynamic> map) => Evaluation(
      courseGroup: map["courseGroup"] as String,
      title: map["title"] as String,
      mark: map["mark"] as double,
      correctedEvaluationOutOf: map["correctedEvaluationOutOf"] as String,
      weight: map["weight"] as double,
      passMark: map["passMark"] as double,
      standardDeviation: map["standardDeviation"] as double,
      median: map["median"] as double,
      percentileRank: map["percentileRank"] as int,
      published: map["published"] as bool,
      teacherMessage: map["teacherMessage"] as String,
      ignore: map["ignore"] as bool,
      targetDate: map["targetDate"] == null
          ? null
          : DateTime.parse(map["targetDate"] as String));

  Map<String, dynamic> toJson() => {
        'courseGroup': courseGroup,
        'title': title,
        'mark': mark,
        'correctedEvaluationOutOf': correctedEvaluationOutOf,
        'weight': weight,
        'passMark': passMark,
        'standardDeviation': standardDeviation,
        'median': median,
        'percentileRank': percentileRank,
        'published': published,
        'teacherMessage': teacherMessage,
        'ignore': ignore,
        'targetDate': targetDate?.toString(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Evaluation &&
          runtimeType == other.runtimeType &&
          courseGroup == other.courseGroup &&
          title == other.title &&
          targetDate == other.targetDate &&
          mark == other.mark &&
          correctedEvaluationOutOf == other.correctedEvaluationOutOf &&
          correctedEvaluationOutOfFormatted ==
              other.correctedEvaluationOutOfFormatted &&
          weight == other.weight &&
          passMark == other.passMark &&
          standardDeviation == other.standardDeviation &&
          median == other.median &&
          percentileRank == other.percentileRank &&
          published == other.published &&
          teacherMessage == other.teacherMessage &&
          ignore == other.ignore;

  @override
  int get hashCode =>
      courseGroup.hashCode ^
      title.hashCode ^
      targetDate.hashCode ^
      mark.hashCode ^
      correctedEvaluationOutOf.hashCode ^
      correctedEvaluationOutOfFormatted.hashCode ^
      weight.hashCode ^
      passMark.hashCode ^
      standardDeviation.hashCode ^
      median.hashCode ^
      percentileRank.hashCode ^
      published.hashCode ^
      teacherMessage.hashCode ^
      ignore.hashCode;

  @override
  String toString() {
    return 'Evaluation{'
        'courseGroup: $courseGroup, '
        'title: $title, '
        'targetDate: $targetDate, '
        'mark: $mark, '
        'correctedEvaluationOutOf: $correctedEvaluationOutOf, '
        'correctedEvaluationOutOfFormatted: $correctedEvaluationOutOfFormatted, '
        'weight: $weight, '
        'passMark: $passMark, '
        'standardDeviation: $standardDeviation, '
        'median: $median, '
        'percentileRank: $percentileRank, '
        'published: $published, '
        'teacherMessage: $teacherMessage, '
        'ignore: $ignore}';
  }
}
