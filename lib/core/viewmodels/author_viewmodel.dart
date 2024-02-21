// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/core/managers/author_repository.dart';
import 'package:notredame/core/managers/news_repository.dart';
import 'package:notredame/core/models/author.dart';
import 'package:notredame/core/models/news.dart';
import 'package:notredame/locator.dart';

class AuthorViewModel extends FutureViewModel<Author> {
  final AuthorRepository _authorRepository = locator<AuthorRepository>();
  final NewsRepository _newsRepository = locator<NewsRepository>();
  final Logger _logger = locator<Logger>();

  /// Localization class of the application.
  final AppIntl appIntl;

  final int authorId;

  /// Author
  late Author _author;

  /// Return the author
  Author get author => _author;

  /// News list
  late List<News> _news;

  /// Return the list of all the news.
  List<News> get news => _news;

  AuthorViewModel({required this.authorId, required this.appIntl});

  bool isLoadingEvents = false;
  bool isNotified = false;

  @override
  Future<Author> futureToRun() async {
    try {
      setBusyForObject(isLoadingEvents, true);
      _author = await _authorRepository.fetchAuthorFromAPI(authorId);
      _news = await _newsRepository.fetchAuthorNewsFromAPI(authorId);
      notifyListeners();
    } catch (e) {
      onError(e);
    } finally {
      setBusyForObject(isLoadingEvents, false);
    }

    return _author;
  }

  @override
  // ignore: type_annotate_public_apis
  void onError(error) {
    Fluttertoast.showToast(msg: appIntl.error);
  }

  Future refresh() async {
    try {
      setBusyForObject(isLoadingEvents, true);
      _author = await _authorRepository.fetchAuthorFromAPI(authorId);
      _news = await _newsRepository.fetchAuthorNewsFromAPI(authorId);
      notifyListeners();
    } on Exception catch (error) {
      onError(error);
    } finally {
      setBusyForObject(isLoadingEvents, false);
    }
  }

  void notifyMe() {
    // TODO activate/deactivate notifications
    isNotified = !isNotified;
    if (isNotified) {
      Fluttertoast.showToast(
          msg: appIntl.news_author_notified_for(author.organisation),
          toastLength: Toast.LENGTH_LONG);
    } else {
      Fluttertoast.showToast(
          msg: appIntl.news_author_not_notified_for(author.organisation),
          toastLength: Toast.LENGTH_LONG);
    }
  }
}
