// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

/// User received from MonETS after a authentication
class MonETSUser {
  final String domaine;

  final int typeUsagerId;

  /// Username of the user
  final String username;

  MonETSUser(
      {@required this.domaine,
      @required this.typeUsagerId,
      @required this.username});

  MonETSUser.fromJson(Map<String, dynamic> json)
      : domaine = json['Domaine'] as String,
        typeUsagerId = json['TypeUsagerId'] as int,
        username = json['Username'] as String;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonETSUser &&
          runtimeType == other.runtimeType &&
          domaine == other.domaine &&
          typeUsagerId == other.typeUsagerId &&
          username == other.username;

  @override
  int get hashCode =>
      domaine.hashCode ^ typeUsagerId.hashCode ^ username.hashCode;
}
