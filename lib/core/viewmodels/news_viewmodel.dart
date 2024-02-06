// FLUTTER / DART / THIRD-PARTIES
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:notredame/core/managers/news_repository.dart';
import 'package:notredame/core/models/news.dart';

import 'package:notredame/locator.dart';

class NewsViewModel extends FutureViewModel<List<News>> {
  /// Load the events
  final NewsRepository _newsRepository = locator<NewsRepository>();

  /// Localization class of the application.
  final AppIntl _appIntl;

  /// News list
  List<News>? _news = [];

  /// Return the list of all the news.
  List<News>? get news {
    _news = [];

    // Build the list of news
    _newsRepository.news?.map((news) => _news?.add(news));

    return _news;
  }

  NewsViewModel({required AppIntl intl}) : _appIntl = intl;

  bool isLoadingEvents = false;

  @override
  Future<List<News>> futureToRun() async {
    try {
      setBusyForObject(isLoadingEvents, true);
      _news = await _newsRepository.getNews(fromCacheOnly: true);
      notifyListeners();
    } catch (e) {
      onError(e);
    } finally {
      setBusyForObject(isLoadingEvents, false);
    }

    return news ?? [];
  }

  @override
  // ignore: type_annotate_public_apis
  void onError(error) {
    Fluttertoast.showToast(msg: _appIntl.error);
  }

  Future refresh() async {
    try {
      setBusyForObject(isLoadingEvents, true);
      _newsRepository.getNews();
      notifyListeners();
    } on Exception catch (error) {
      onError(error);
    }
  }
}
