// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

class News {
  final int id;
  final String title;
  final String description;
  final String image;
  // À changer pour une liste de tags
  final List<String> tags;
  final DateTime date;
  final bool important;

  News(
      {@required this.id,
        @required this.title,
        @required this.description,
        @required this.image,
        @required this.tags,
        @required this.date,
        @required this.important});

  /// Used to create [News] instance from a JSON file
  factory News.fromJson(Map<String, dynamic> map) => News(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      image: map['image'] as String,
      tags: List<String>.from(map['tags'] as List),
      date: DateTime.parse(map['date'] as String),
      important: map['important'] as bool);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'image': image,
        'tags': tags,
        'date': date.toString(),
        'important': important
      };
}

