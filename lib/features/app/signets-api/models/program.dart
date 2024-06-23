// FLUTTER / DART / THIRD-PARTIES
import 'package:xml/xml.dart';

class Program {
  /// Name of the program
  final String name;

  /// Code of the program (ex: 0725)
  final String code;

  /// Average grade of the program (x.xx / 4.30)
  final String average;

  /// Number of accumulated credits for the program
  final String accumulatedCredits;

  /// Number of registered credits for the program
  final String registeredCredits;

  /// Number of completed courses for the program
  final String completedCourses;

  /// Number of failed courses for the program
  final String failedCourses;

  /// Number of equivalent courses for the program
  final String equivalentCourses;

  /// Status of the program (Actif, Diplome)
  final String status;

  Program(
      {required this.name,
      required this.code,
      required this.average,
      required this.accumulatedCredits,
      required this.registeredCredits,
      required this.completedCourses,
      required this.failedCourses,
      required this.equivalentCourses,
      required this.status});

  /// Used to create a new [Program] instance from a [XMLElement].
  factory Program.fromXmlNode(XmlElement node) => Program(
      name: node.getElement('libelle')!.innerText,
      code: node.getElement('code')!.innerText,
      average: node.getElement('moyenne')!.innerText,
      accumulatedCredits: node.getElement('nbCreditsCompletes')!.innerText,
      registeredCredits: node.getElement('nbCreditsInscrits')!.innerText,
      completedCourses: node.getElement('nbCrsReussis')!.innerText,
      failedCourses: node.getElement('nbCrsEchoues')!.innerText,
      equivalentCourses: node.getElement('nbEquivalences')!.innerText,
      status: node.getElement('statut')!.innerText);

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Program &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          code == other.code &&
          average == other.average &&
          accumulatedCredits == other.accumulatedCredits &&
          registeredCredits == other.registeredCredits &&
          completedCourses == other.completedCourses &&
          failedCourses == other.failedCourses &&
          equivalentCourses == other.equivalentCourses &&
          status == other.status;

  @override
  int get hashCode =>
      name.hashCode ^
      code.hashCode ^
      average.hashCode ^
      accumulatedCredits.hashCode ^
      registeredCredits.hashCode ^
      completedCourses.hashCode ^
      failedCourses.hashCode ^
      equivalentCourses.hashCode ^
      status.hashCode;
}
