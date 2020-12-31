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
      balance: node.getElement('soldeTotal').innerText,
      firstName: node.getElement('prenom').innerText,
      lastName: node.getElement('nom').innerText,
      permanentCode: node.getElement('codePerm').innerText);

  /// Used to create [ProfileStudent] instance from a JSON file
  factory ProfileStudent.fromJson(Map<String, dynamic> map) => ProfileStudent(
        balance: map['soldeTotal'] as String,
        firstName: map['prenom'] as String,
        lastName: map['nom'] as String,
        permanentCode: map['codePerm'] as String,
      );

  Map<String, dynamic> toJson() => {
        'soldeTotal': balance,
        'prenom': firstName,
        'nom': lastName,
        'codePerm': permanentCode
      };
}
