// FLUTTER / DART / THIRD-PARTIES

// Package imports:
import 'package:xml/xml.dart';

class ProfileStudent {
  /// Balance of the student
  final String balance;

  /// First name of the student
  final String firstName;

  /// Last name of the student
  final String lastName;

  /// Permanent code of the student (XXXX00000000)
  final String permanentCode;

  /// Universal code of the student (XX000000)
  final String universalCode;

  ProfileStudent(
      {required this.balance,
      required this.firstName,
      required this.lastName,
      required this.permanentCode,
      required this.universalCode});

  /// Used to create a new [ProfileStudent] instance from a [XMLElement].
  factory ProfileStudent.fromXmlNode(XmlElement node) => ProfileStudent(
      lastName: node.getElement('nom')!.innerText.trimRight(),
      firstName: node.getElement('prenom')!.innerText.trimRight(),
      permanentCode: node.getElement('codePerm')!.innerText,
      universalCode: node.getElement('codeUniversel')!.innerText,
      balance: node.getElement('soldeTotal')!.innerText);

  /// Used to create [ProfileStudent] instance from a JSON file
  factory ProfileStudent.fromJson(Map<String, dynamic> map) => ProfileStudent(
      lastName: map['nom'] as String,
      firstName: map['prenom'] as String,
      permanentCode: map['codePerm'] as String,
      universalCode: map.containsKey("codeUniversel") ? map['codeUniversel'] as String : '',
      balance: map['soldeTotal'] as String);

  Map<String, dynamic> toJson() => {
        'nom': lastName.trimRight(),
        'prenom': firstName.trimRight(),
        'codePerm': permanentCode,
        'codeUniversel': universalCode,
        'soldeTotal': balance
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileStudent &&
          runtimeType == other.runtimeType &&
          lastName == other.lastName &&
          firstName == other.firstName &&
          permanentCode == other.permanentCode &&
          universalCode == other.universalCode &&
          balance == other.balance;

  @override
  int get hashCode => lastName.hashCode ^ firstName.hashCode ^ permanentCode.hashCode ^ balance.hashCode;
}
