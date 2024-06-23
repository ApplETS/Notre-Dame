// FLUTTER / DART / THIRD-PARTIES
import 'package:ets_api_clients/models.dart';

/// Data-class that represent an hello-based news
class News {
  /// News unique Id
  final String id;

  /// A news title
  final String title;

  /// The news content
  final String content;

  /// The imageUrl of the news
  final String? imageUrl;

  /// The current state of the news
  final String state;

  /// The date that the news was created at
  final DateTime publicationDate;

  /// Date when the event start
  final DateTime eventStartDate;

  /// Date when the event end
  final DateTime eventEndDate;

  final DateTime createdAt;

  final DateTime updatedAt;

  final Organizer organizer;

  final List<NewsTags> tags;

  News(
      {required this.id,
      required this.title,
      required this.content,
      this.imageUrl,
      required this.state,
      required this.tags,
      required this.publicationDate,
      required this.eventStartDate,
      required this.eventEndDate,
      required this.createdAt,
      required this.updatedAt,
      required this.organizer});

  /// Used to create [CourseActivity] instance from a JSON file
  factory News.fromJson(Map<String, dynamic> map) => News(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      imageUrl: map['imageUrl'] as String?,
      state: map['state'] as String,
      tags: (map['tags'] as List<dynamic>)
          .map((e) => NewsTags.fromJson(e as Map<String, dynamic>))
          .toList(),
      publicationDate: DateTime.parse(map['publicationDate'] as String),
      eventStartDate: DateTime.parse(map['eventStartDate'] as String),
      eventEndDate: DateTime.parse(map['eventEndDate'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      organizer: Organizer.fromJson(map['organizer'] as Map<String, dynamic>));

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'imageUrl': imageUrl,
        'state': state,
        'tags': tags.map((e) => e.toJson()).toList(),
        'publicationDate': publicationDate.toString(),
        'eventStartDate': eventStartDate.toString(),
        'eventEndDate': eventEndDate.toString(),
        'createdAt': createdAt.toString(),
        'updatedAt': updatedAt.toString(),
        'organizer': organizer.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is News &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          content == other.content &&
          imageUrl == other.imageUrl &&
          state == other.state &&
          tags == other.tags &&
          publicationDate == other.publicationDate &&
          eventStartDate == other.eventStartDate &&
          eventEndDate == other.eventEndDate &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          organizer == other.organizer;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      content.hashCode ^
      imageUrl.hashCode ^
      state.hashCode ^
      tags.hashCode ^
      publicationDate.hashCode ^
      eventStartDate.hashCode ^
      eventEndDate.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      organizer.hashCode;
}
