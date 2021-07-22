// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

/// Data-class that represent an activity of a course
class CourseProfessor {
  /// Professor's first name
  final String firstName;

  /// Professor's last name
  final String lastName;

  /// Professor's email
  final String email;

  /// office location of the professor
  final String officeLocation;

  /// phone number of the professor
  final String phoneNumber;

  /// if this professor is the main professor for the course
  /// At the moment, it only fetch those who are in fact the main professor
  /// There is no practical work professor
  final bool isPrincipalProfessor;

  CourseProfessor(
      {@required this.firstName,
      @required this.lastName,
      @required this.email,
      @required this.officeLocation,
      @required this.phoneNumber,
      @required this.isPrincipalProfessor});

  /// Used to create a new [CourseActivity] instance from a [XMLElement].
  factory CourseProfessor.fromXmlNode(XmlElement node) => CourseProfessor(
      firstName: node.getElement('prenom').innerText,
      lastName: node.getElement('nom').innerText,
      email: node.getElement('courriel').innerText,
      officeLocation: node.getElement('localBureau').innerText,
      phoneNumber: node.getElement('telephone').innerText,
      isPrincipalProfessor:
          node.getElement('enseignantPrincipal').innerText == "Oui");

  /// Used to create [CourseActivity] instance from a JSON file
  factory CourseProfessor.fromJson(Map<String, dynamic> map) => CourseProfessor(
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      email: map['email'] as String,
      officeLocation: map['officeLocation'] as String,
      phoneNumber: map['phoneNumber'] as String,
      isPrincipalProfessor:
          map['isPrincipalProfessor'] as String == true.toString());

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'officeLocation': officeLocation,
        'phoneNumber': phoneNumber,
        'isPrincipalProfessor': isPrincipalProfessor.toString()
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseProfessor &&
          runtimeType == other.runtimeType &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          email == other.email &&
          officeLocation == other.officeLocation &&
          phoneNumber == other.phoneNumber &&
          isPrincipalProfessor == other.isPrincipalProfessor;

  @override
  int get hashCode =>
      firstName.hashCode ^
      lastName.hashCode ^
      email.hashCode ^
      officeLocation.hashCode ^
      phoneNumber.hashCode ^
      isPrincipalProfessor.hashCode;
}
