import 'package:flutter/material.dart';
import 'package:notredame/core/models/tags.dart';

class News {
  final int id;
  final String title;
  final String description;
  final String image;
  final List<Tag> tags;
  final DateTime date;

  News({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.image,
    @required this.tags,
    @required this.date,
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
    };
  }
}
