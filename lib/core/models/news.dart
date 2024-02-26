class News {
  final int id;
  final String title;
  final String description;
  final String author;
  final int authorId;
  final String avatar;
  final String activity;
  final String image;
  final List<String> tags;
  final DateTime publishedDate;
  final DateTime eventDate;
  final DateTime publishedDate;
  final DateTime eventDate;

  News({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.authorId,
    required this.avatar,
    required this.activity,
    required this.image,
    required this.tags,
    required this.publishedDate,
    required this.eventDate,
    required this.publishedDate,
    required this.eventDate,
  });

  /// Used to create [News] instance from a JSON file
  factory News.fromJson(Map<String, dynamic> map) {
    return News(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      author: map['author'] as String,
      authorId: map['authorId'] as int,
      avatar: map['avatar'] as String,
      activity: map['activity'] as String,
      image: map['image'] as String,
      tags: map['tags'] as List<String>,
      publishedDate: DateTime.parse(map['publishedDate'] as String),
      eventDate: DateTime.parse(map['eventDate'] as String),
      publishedDate: DateTime.parse(map['publishedDate'] as String),
      eventDate: DateTime.parse(map['eventDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'author': author,
      'authorId': authorId,
      'avatar': avatar,
      'activity': activity,
      'image': image,
      'tags': tags.toList(),
      'publishedDate': publishedDate.toString(),
      'eventDate': eventDate.toString(),
      'publishedDate': publishedDate.toString(),
      'eventDate': eventDate.toString(),
    };
  }
}
