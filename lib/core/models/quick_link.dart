// Flutter imports:
import 'package:flutter/material.dart';

class QuickLink {
  final int id;
  Widget image;
  final String link;
  final String nameFr;
  final String nameEn;
  String name;

  // If name is provided it will be used instead of nameFr and nameEn
  QuickLink(
      {@required this.id,
      this.image,
      this.name,
      this.nameFr,
      this.nameEn,
      @required this.link});

  factory QuickLink.fromJson(Map<String, dynamic> json) {
    return QuickLink(
      id: int.parse(json['id'] as String),
      nameFr: json['nameFr'] as String,
      nameEn: json['nameEn'] as String,
      link: json['link'] as String,
    );
  }
}
