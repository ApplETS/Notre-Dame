// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:notredame/core/models/evaluation.dart';
import 'package:xml/xml.dart';

/// Data class that represent the current mark, score, ... of a course
class CourseSummary {
  /// Mark obtained by the student.
  /// (ex: 24)
  final double currentMark;

  /// Mark obtained by the student in percent.
  /// (ex: 24)
  final double currentMarkInPercent;

  /// On how much the course is actually corrected (ex: 30)
  /// Sum of all the evaluations weight already published.
  final double markOutOf;

  /// Average mark of the class (ex: 30)
  final double passMark;

  /// Standard deviation of the class
  final double standardDeviation;

  /// Median of the class
  final double median;

  /// Percentile rank of the student on this course
  final int percentileRank;

  /// All the evaluations for this courses.
  final List<Evaluation> evaluations;

  CourseSummary(
      {@required this.currentMark,
      @required this.currentMarkInPercent,
      @required this.markOutOf,
      @required this.passMark,
      @required this.standardDeviation,
      @required this.median,
      @required this.percentileRank,
      @required this.evaluations});

  /// Used to create a new [CourseSummary] instance from a [XMLElement].
  factory CourseSummary.fromXmlNode(XmlElement node) => CourseSummary(
      currentMark: double.parse(
          node.getElement("scoreFinaleSur100").innerText.replaceAll(",", ".")),
      currentMarkInPercent: double.parse(
          node.getElement("noteACeJour").innerText.replaceAll(",", ".")),
      markOutOf: double.parse(
          node.getElement("tauxPublication").innerText.replaceAll(",", ".")),
      passMark: double.parse(
          node.getElement("moyenneClasse").innerText.replaceAll(",", ".")),
      standardDeviation: double.parse(
          node.getElement("ecartTypeClasse").innerText.replaceAll(",", ".")),
      median: double.parse(
          node.getElement("medianeClasse").innerText.replaceAll(",", ".")),
      percentileRank: int.parse(node.getElement("rangCentileClasse").innerText),
      evaluations: node
          .findAllElements("ElementEvaluation")
          .map((node) => Evaluation.fromXml(node))
          .toList());

  /// Used to create [CourseSummary] instance from a JSON file
  factory CourseSummary.fromJson(Map<String, dynamic> json) => CourseSummary(
      currentMark: json["currentMark"] as double,
      currentMarkInPercent: json["currentMarkInPercent"] as double,
      markOutOf: json["markOutOf"] as double,
      passMark: json["passMark"] as double,
      standardDeviation: json["standardDeviation"] as double,
      median: json["median"] as double,
      percentileRank: json["percentileRank"] as int,
      evaluations: (json["evaluations"] as List)
          .map<Evaluation>(
              (e) => Evaluation.fromJson(e as Map<String, dynamic>))
          .toList());

  Map<String, dynamic> toJson() => {
        "currentMark": currentMark,
        "currentMarkInPercent": currentMarkInPercent,
        "markOutOf": markOutOf,
        "passMark": passMark,
        "standardDeviation": standardDeviation,
        "median": median,
        "percentileRank": percentileRank,
        "evaluations": evaluations
      };

  @override
  String toString() {
    return 'CourseSummary{'
        'currentMark: $currentMark, '
        'currentMarkInPercent: $currentMarkInPercent, '
        'markOutOf: $markOutOf, '
        'passMark: $passMark, '
        'standardDeviation: $standardDeviation, '
        'median: $median, '
        'percentileRank: $percentileRank, '
        'evaluations: $evaluations}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseSummary &&
          runtimeType == other.runtimeType &&
          currentMark == other.currentMark &&
          currentMarkInPercent == other.currentMarkInPercent &&
          markOutOf == other.markOutOf &&
          passMark == other.passMark &&
          standardDeviation == other.standardDeviation &&
          median == other.median &&
          percentileRank == other.percentileRank &&
          listEquals(evaluations, other.evaluations);

  @override
  int get hashCode =>
      currentMark.hashCode ^
      currentMarkInPercent.hashCode ^
      markOutOf.hashCode ^
      passMark.hashCode ^
      standardDeviation.hashCode ^
      median.hashCode ^
      percentileRank.hashCode ^
      evaluations.hashCode;
}
