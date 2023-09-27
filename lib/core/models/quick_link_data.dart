// Flutter imports:
import 'package:flutter/material.dart';

class QuickLinkData {
  final int id;
  final int index;

  QuickLinkData({@required this.id, @required this.index});

  factory QuickLinkData.fromJson(Map<String, dynamic> json) {
    return QuickLinkData(
      id: json['id'] as int,
      index: json['index'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'index': index,
    };
  }
}
