// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// MODELS
import 'package:notredame/core/models/news.dart';
import 'package:notredame/core/models/tags.dart';

void main() {
  group('News class tests', () {
    test('News.fromJson() should parse JSON correctly', () {
      final json = {
        'id': 1,
        'title': 'Test Title',
        'description': 'Test Description',
        'image': 'https://example.com/image.jpg',
        'tags': [
          {'text': 'Tag 1', 'color': Colors.blue.value},
          {'text': 'Tag 2', 'color': Colors.red.value},
        ],
        'date': '2022-01-01T12:00:00Z',
        'important': true,
      };

      final news = News.fromJson(json);

      expect(news.id, equals(1));
      expect(news.title, equals('Test Title'));
      expect(news.description, equals('Test Description'));
      expect(news.image, equals('https://example.com/image.jpg'));
      expect(news.tags.length, equals(2));
      expect(news.tags[0].text, equals('Tag 1'));
      expect(news.tags[0].color, equals(Colors.blue[500]));
      expect(news.tags[1].text, equals('Tag 2'));
      expect(news.tags[1].color, equals(Colors.red[500]));
      expect(news.date, equals(DateTime.parse('2022-01-01T12:00:00Z')));
      expect(news.important, isTrue);
    });

    test('toJson() should convert News to JSON correctly', () {
      final news = News(
        id: 1,
        title: 'Test Title',
        description: 'Test Description',
        image: 'https://example.com/image.jpg',
        tags: [
          Tag(text: 'Tag 1', color: Colors.blue[500]),
          Tag(text: 'Tag 2', color: Colors.red[500]),
        ],
        date: DateTime.parse('2022-01-01T12:00:00Z'),
        important: true,
      );

      final json = news.toJson();

      expect(json['id'], equals(1));
      expect(json['title'], equals('Test Title'));
      expect(json['description'], equals('Test Description'));
      expect(json['image'], equals('https://example.com/image.jpg'));
      expect(json['tags'], hasLength(2));
      expect(json['tags'][0]['text'], equals('Tag 1'));
      expect(json['tags'][0]['color'], equals(Colors.blue[500].value));
      expect(json['tags'][1]['text'], equals('Tag 2'));
      expect(json['tags'][1]['color'], equals(Colors.red[500].value));
      expect(json['date'], equals('2022-01-01 12:00:00.000Z'));
      expect(json['important'], isTrue);
    });
  });

  group('Tag class tests', () {
    test('Tag.fromJson() should parse JSON correctly', () {
      final json = {
        'text': 'Test Tag',
        'color': Colors.blue[500].value,
      };

      final tag = Tag.fromJson(json);

      expect(tag.text, equals('Test Tag'));
      expect(tag.color, equals(Colors.blue[500]));
    });

    test('toJson() should convert Tag to JSON correctly', () {
      final tag = Tag(text: 'Test Tag', color: Colors.blue[500]);

      final json = tag.toJson();

      expect(json['text'], equals('Test Tag'));
      expect(json['color'], equals(Colors.blue[500].value));
    });
  });
}
