// FLUTTER / DART / THIRD-PARTIES
import 'dart:ui';

import 'package:notredame/core/models/news.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:stacked/stacked.dart';

class NewsDetailsViewModel extends FutureViewModel<News> {
  News news;

  NewsDetailsViewModel({required this.news});

  List<Color> tagsPalette = AppTheme.tagsPalette.toList();

  /// A map that contains a color from the AppTheme.tagsPalette palette associated with each tags.
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
