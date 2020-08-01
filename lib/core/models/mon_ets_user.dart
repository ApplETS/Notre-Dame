// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

/// User received from MonETS after a authentication
class MonETSUser {
  final String domain;

  final int typeUsagerId;

  /// Username of the user
  final String username;

  MonETSUser(
      {@required this.domain,
      @required this.typeUsagerId,
      @required this.username});

  MonETSUser.fromJson(Map<String, dynamic> json)
      : domain = json['Domaine'] as String,
        typeUsagerId = json['TypeUsagerId'] as int,
        username = json['Username'] as String;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonETSUser &&
          runtimeType == other.runtimeType &&
          domain == other.domain &&
          typeUsagerId == other.typeUsagerId &&
          username == other.username;

  @override
  int get hashCode =>
      domain.hashCode ^ typeUsagerId.hashCode ^ username.hashCode;
}
