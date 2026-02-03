import 'package:fluttertoast/fluttertoast.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stacked/stacked.dart';

import 'package:notredame/data/models/hello/news.dart';
import 'package:notredame/data/models/hello/organizer.dart';
import 'package:notredame/data/repositories/author_repository.dart';
import 'package:notredame/data/repositories/news_repository.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';

class AuthorViewModel extends BaseViewModel implements Initialisable {
  final AuthorRepository _authorRepository = locator<AuthorRepository>();
  final NewsRepository _newsRepository = locator<NewsRepository>();

  final AppIntl appIntl;
  final String authorId;

  Organizer? _author;
  Organizer? get author => _author;

  late final PagingController<int, News> pagingController;

  bool isNotified = false;

  AuthorViewModel({
    required this.authorId,
    required this.appIntl,
  });

  @override
  Future<void> initialise() async {
    pagingController = PagingController<int, News>(
      getNextPageKey: (state) {
        if (state.lastPageIsEmpty) return null;
        return state.nextIntPageKey;
      },
      fetchPage: _fetchPage,
    );
  }

  Future<List<News>> _fetchPage(int pageNumber) async {
    final pagination = await _newsRepository.getNews(
      pageNumber: pageNumber,
      organizerId: authorId,
    );

    return pagination?.news ?? [];
  }

  Future<void> fetchAuthorData() async {
    setBusy(true);
    try {
      _author = await _authorRepository.getOrganizer(authorId);
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  void notifyMe() {
    // TODO activate/deactivate notifications
    isNotified = !isNotified;

    Fluttertoast.showToast(
      msg: isNotified
          ? appIntl.news_author_notified_for(author?.organization ?? "")
          : appIntl.news_author_not_notified_for(author?.organization ?? ""),
      toastLength: Toast.LENGTH_LONG,
    );
  }

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }
}
