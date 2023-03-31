// FLUTTER / DART / THIRD-PARTIES
import 'dart:math';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// CONSTANTS

// MANAGER
import 'package:notredame/core/managers/news_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';

// MODELS
import 'package:notredame/core/models/News.dart';

// UTILS

// OTHER
import 'package:notredame/locator.dart';

class NewsViewModel extends FutureViewModel<List<News>> {
  /// Load the events
  final NewsRepository _newsRepository = locator<NewsRepository>();

  /// Manage de settings
  final SettingsManager _settingsManager = locator<SettingsManager>();

  /// Localization class of the application.
  final AppIntl _appIntl;

  /// News list
  List<News> _news = [];

  /// Return the list of all the news.
  List<News> get news {
    _news = [];

    // Build the list of news
    for (final n in _newsRepository.news) {
      _news.add(n);
    }

    return _news;
  }

  /// Get current locale
  Locale get locale => _settingsManager.locale;

  NewsViewModel({@required AppIntl intl}) : _appIntl = intl;

  bool isLoadingEvents = false;

  @override
  Future<List<News>> futureToRun() =>
      // ignore: missing_return
      _newsRepository.getNews(fromCacheOnly: true).then((value) {
        setBusyForObject(isLoadingEvents, true);
        _newsRepository
            .getNews()
        // ignore: return_type_invalid_for_catch_error
            .catchError(onError)
            .then((value) {
          if (value != null) {
            // Reload the list of news
            news;
          }
          }).whenComplete(() {
            setBusyForObject(isLoadingEvents, false);
          });
        });

  @override
  // ignore: type_annotate_public_apis
  void onError(error) {
    Fluttertoast.showToast(msg: _appIntl.error);
  }

}
