// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

class ProfileStudent {
  final String balance;
  final String firstName;
  final String lastName;
  final String permanentCode;

  ProfileStudent(
      {@required this.balance,
      @required this.firstName,
      @required this.lastName,
      @required this.permanentCode});

  /// Used to create a new [ProfileStudent] instance from a [XMLElement].
  factory ProfileStudent.fromXmlNode(XmlElement node) => ProfileStudent(
      lastName: node.getElement('nom').innerText.trimRight(),
      firstName: node.getElement('prenom').innerText.trimRight(),
      permanentCode: node.getElement('codePerm').innerText,
      balance: node.getElement('soldeTotal').innerText);

  /// Used to create [ProfileStudent] instance from a JSON file
  factory ProfileStudent.fromJson(Map<String, dynamic> map) => ProfileStudent(
      lastName: map['nom'] as String,
      firstName: map['prenom'] as String,
      permanentCode: map['codePerm'] as String,
      balance: map['soldeTotal'] as String);

  Map<String, dynamic> toJson() => {
        'nom': lastName.trimRight(),
        'prenom': firstName.trimRight(),
        'codePerm': permanentCode,
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
          balance == other.balance;

  @override
  int get hashCode =>
      lastName.hashCode ^
      firstName.hashCode ^
      permanentCode.hashCode ^
      balance.hashCode;
}
