import 'package:flutter/material.dart';

class Tag {
  final String text;
  final Color color;

  Tag({
    @required this.text,
    @required this.color,
  });

  factory Tag.fromJson(dynamic tagMap) {
    if (tagMap is Map<String, dynamic>) {
      return Tag(
        text: tagMap['text'] as String,
        color: Color(tagMap['color'] as int),
      );
    }
    throw ArgumentError('Invalid tagMap type. Expected Map<String, dynamic>.');
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'color': color.value,
    };
  }
}