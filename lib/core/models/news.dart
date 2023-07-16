import 'package:flutter/material.dart';

class News {
  final int id;
  final String title;
  final String description;
  final String image;
  final List<Tag> tags;
  final DateTime date;
  final bool important;

  News({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.image,
    @required this.tags,
    @required this.date,
    @required this.important,
  });

  /// Used to create [News] instance from a JSON file
  factory News.fromJson(Map<String, dynamic> map) {
    return News(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      image: map['image'] as String,
      tags: List<Tag>.from(
          (map['tags'] as List).map((tagMap) => Tag.fromJson(tagMap))),
      date: DateTime.parse(map['date'] as String),
      important: map['important'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'tags': tags.map((tag) => tag.toJson()).toList(),
      'date': date.toString(),
      'important': important,
    };
  }
}

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
