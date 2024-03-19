// Package imports:
import 'package:ets_api_clients/models.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/core/managers/author_repository.dart';
import 'package:notredame/core/managers/news_repository.dart';
import 'package:notredame/core/models/author.dart';
import 'package:notredame/locator.dart';

class AuthorViewModel extends BaseViewModel implements Initialisable {
  final AuthorRepository _authorRepository = locator<AuthorRepository>();
  final NewsRepository _newsRepository = locator<NewsRepository>();
  final Logger _logger = locator<Logger>();

  /// Localization class of the application.
  final AppIntl appIntl;

  final String authorId;

  /// Author
  Author? _author;

  /// Return the author
  Author? get author => _author;

  final PagingController<int, News> pagingController =
      PagingController(firstPageKey: 1);

  AuthorViewModel({required this.authorId, required this.appIntl});

  bool isLoadingEvents = false;
  bool isNotified = false;

  @override
  void initialise() {
    // This will be called when init state cycle runs
    pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });
    _author = _authorRepository.fetchAuthorFromAPI(authorId);
  }

  Future<void> fetchPage(int pageNumber) async {
    try {
      final pagination = await _newsRepository.getNews(pageNumber: pageNumber);
      final isLastPage = pagination?.totalPages == pageNumber;
      if (isLastPage) {
        pagingController.appendLastPage(pagination?.news ?? []);
      } else {
        final nextPageKey = pageNumber + 1;
        pagingController.appendPage(pagination?.news ?? [], nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }

  void notifyMe() {
    // TODO activate/deactivate notifications
    isNotified = !isNotified;
    if (isNotified) {
      Fluttertoast.showToast(
          msg: appIntl.news_author_notified_for(author?.organisation ?? ""),
          toastLength: Toast.LENGTH_LONG);
    } else {
      Fluttertoast.showToast(
          msg: appIntl.news_author_not_notified_for(author?.organisation ?? ""),
          toastLength: Toast.LENGTH_LONG);
    }
  }
}
