// ignore_for_file: avoid_dynamic_calls

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/core/models/news.dart';

void main() {
  group('News class tests', () {
    test('News.fromJson() should parse JSON correctly', () {
      final json = {
        'id': 1,
        'title': 'Test Title',
        'description': 'Test Description',
        'image': 'https://example.com/image.jpg',
        'tags': ['Tag 1', 'Tag 2'],
        'date': '2022-01-01T12:00:00Z',
      };

      final news = News.fromJson(json);

      expect(news.id, equals(1));
      expect(news.title, equals('Test Title'));
      expect(news.description, equals('Test Description'));
      expect(news.image, equals('https://example.com/image.jpg'));
      expect(news.tags.length, equals(2));
      expect(news.tags[0], equals('Tag 1'));
      expect(news.tags[1], equals('Tag 2'));
      expect(news.date, equals(DateTime.parse('2022-01-01T12:00:00Z')));
    });

    test('toJson() should convert News to JSON correctly', () {
      final news = News(
        id: 1,
        title: 'Test Title',
        description: 'Test Description',
        image: 'https://example.com/image.jpg',
        tags: [
          'Tag 1',
          'Tag 2',
        ],
        date: DateTime.parse('2022-01-01T12:00:00Z'),
      );

      final json = news.toJson();

      expect(json['id'], equals(1));
      expect(json['title'], equals('Test Title'));
      expect(json['description'], equals('Test Description'));
      expect(json['image'], equals('https://example.com/image.jpg'));
      expect(json['tags'], hasLength(2));
      expect(json['tags'][0], equals('Tag 1'));
      expect(json['tags'][1], equals('Tag 2'));
      expect(json['date'], equals('2022-01-01 12:00:00.000Z'));
    });
  });
}
