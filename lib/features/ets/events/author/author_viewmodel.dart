import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stacked/stacked.dart';
import 'package:notredame/features/app/repository/author_repository.dart';
import 'package:notredame/features/app/repository/news_repository.dart';
import 'package:notredame/features/ets/events/api-client/models/news.dart';
import 'package:notredame/features/ets/events/api-client/models/organizer.dart';
import 'package:notredame/utils/locator.dart';

class AuthorViewModel extends BaseViewModel implements Initialisable {
  final AuthorRepository _authorRepository = locator<AuthorRepository>();
  final NewsRepository _newsRepository = locator<NewsRepository>();

  final AppIntl appIntl;
  final String authorId;

  Organizer? _author;
  Organizer? get author => _author;

  final PagingController<int, News> pagingController =
      PagingController(firstPageKey: 1);

  AuthorViewModel({required this.authorId, required this.appIntl});

  bool isLoadingEvents = false;
  bool isNotified = false;

  @override
  Future<void> initialise() async {
    pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });
  }

  Future<void> fetchPage(int pageNumber) async {
    try {
      final pagination = await _newsRepository.getNews(
          pageNumber: pageNumber, organizerId: authorId);
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
    isNotified = !isNotified;
    if (isNotified) {
      Fluttertoast.showToast(
        msg: appIntl.news_author_notified_for(author?.organization ?? ""),
        toastLength: Toast.LENGTH_LONG,
      );
    } else {
      Fluttertoast.showToast(
        msg: appIntl.news_author_not_notified_for(author?.organization ?? ""),
        toastLength: Toast.LENGTH_LONG,
      );
    }
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
}
