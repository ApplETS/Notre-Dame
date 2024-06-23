// Dart imports:
import 'dart:ui';

// Package imports:
import 'package:notredame/features/ets/events/api-client/models/news.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/utils/app_theme.dart';

class NewsDetailsViewModel extends FutureViewModel<News> {
  News news;

  NewsDetailsViewModel({required this.news});

  List<Color> tagsPalette = AppTheme.tagsPalette.toList();

  final Map<String, Color> tagColors = {};

  @override
  Future<News> futureToRun() {
    return Future.value(news);
  }

  Color? getTagColor(String tag) {
    if (!tagColors.containsKey(tag)) {
      tagColors[tag] = tagsPalette.removeLast();
    }
    return tagColors[tag];
  }
}
