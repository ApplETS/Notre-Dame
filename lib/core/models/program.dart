// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

class Program {
  final String name;
  final String code;
  final String average;
  final String accumulatedCredits;
  final String registeredCredits;
  final String completedCourses;
  final String failedCourses;
  final String equivalentCourses;
  final String status;

  Program(
      {@required this.name,
      @required this.code,
      @required this.average,
      @required this.accumulatedCredits,
      @required this.registeredCredits,
      @required this.completedCourses,
      @required this.failedCourses,
      @required this.equivalentCourses,
      @required this.status});

  /// Used to create a new [Program] instance from a [XMLElement].
  factory Program.fromXmlNode(XmlElement node) => Program(
      name: node.getElement('libelle').innerText,
      code: node.getElement('code').innerText,
      average: node.getElement('moyenne').innerText,
      accumulatedCredits: node.getElement('nbCreditsCompletes').innerText,
      registeredCredits: node.getElement('nbCreditsInscrits').innerText,
      completedCourses: node.getElement('nbCrsReussis').innerText,
      failedCourses: node.getElement('nbCrsEchoues').innerText,
      equivalentCourses: node.getElement('nbEquivalences').innerText,
      status: node.getElement('statut').innerText);

  /// Used to create [CourseActivity] instance from a JSON file
  factory Program.fromJson(Map<String, dynamic> map) => Program(
      name: map['libelle'] as String,
      code: map['code'] as String,
      average: map['moyenne'] as String,
      accumulatedCredits: map['nbCreditsCompletes'] as String,
      registeredCredits: map['nbCreditsInscrits'] as String,
      completedCourses: map['nbCrsReussis'] as String,
      failedCourses: map['nbCrsEchoues'] as String,
      equivalentCourses: map['nbEquivalences'] as String,
      status: map['statut'] as String);

  Map<String, dynamic> toJson() => {
        'libelle': name,
        'code': code,
        'moyenne': average,
        'nbCreditsCompletes': accumulatedCredits,
        'nbCreditsInscrits': registeredCredits,
        'nbCrsReussis': completedCourses,
        'nbCrsEchoues': failedCourses,
        'nbEquivalences': equivalentCourses,
        'statut': status,
      };
}
