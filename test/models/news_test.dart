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
        'authorId': 1,
        'author': 'Author',
        'avatar': 'https://example.com/image.jpg',
        'activity': 'Club scientifique',
        'image': 'https://example.com/image.jpg',
        'tags': ['Tag 1', 'Tag 2'],
        'publishedDate': '2022-01-01T12:00:00Z',
        'eventDate': '2022-01-01T12:00:00Z',
      };

      final news = News.fromJson(json);
      expect(news.id, equals(1));
      expect(news.title, equals('Test Title'));
      expect(news.description, equals('Test Description'));
      expect(news.author, equals('Author'));
      expect(news.authorId, equals(1));
      expect(news.avatar, equals('https://example.com/image.jpg'));
      expect(news.activity, equals('Club scientifique'));
      expect(news.image, equals('https://example.com/image.jpg'));
      expect(news.tags.length, equals(2));
      expect(news.tags[0], equals('Tag 1'));
      expect(news.tags[1], equals('Tag 2'));
      expect(
          news.publishedDate, equals(DateTime.parse('2022-01-01T12:00:00Z')));
      expect(news.eventDate, equals(DateTime.parse('2022-01-01T12:00:00Z')));
    });

    test('toJson() should convert News to JSON correctly', () {
      final news = News(
        id: 1,
        title: 'Test Title',
        description: 'Test Description',
        authorId: 1,
        author: 'Author',
        avatar: 'https://example.com/image.jpg',
        activity: 'Club scientifique',
        image: 'https://example.com/image.jpg',
        tags: ['Tag 1', 'Tag 2'],
        publishedDate: DateTime.parse('2022-01-01T12:00:00.000Z'),
        eventDate: DateTime.parse('2022-01-01T12:00:00.000Z'),
      );

      final json = news.toJson();

      expect(json['id'], equals(1));
      expect(json['title'], equals('Test Title'));
      expect(json['description'], equals('Test Description'));
      expect(json['authorId'], equals(1));
      expect(json['author'], equals('Author'));
      expect(json['avatar'], equals('https://example.com/image.jpg'));
      expect(json['activity'], equals('Club scientifique'));
      expect(json['image'], equals('https://example.com/image.jpg'));
      expect(json['tags'], hasLength(2));
      expect(json['tags'][0], equals('Tag 1'));
      expect(json['publishedDate'], equals('2022-01-01 12:00:00.000Z'));
      expect(json['eventDate'], equals('2022-01-01 12:00:00.000Z'));
    });
  });
}
