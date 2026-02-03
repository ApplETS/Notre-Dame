// Package imports:
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/models/hello/news.dart';
import 'package:notredame/data/repositories/news_repository.dart';
import 'package:notredame/locator.dart';

class NewsViewModel extends BaseViewModel implements Initialisable {
  /// Load the events
  final NewsRepository _newsRepository = locator<NewsRepository>();

  late final PagingController<int, News> pagingController;

  String title = "";

  @override
  void initialise() {
    pagingController = PagingController<int, News>(
      getNextPageKey: (state) {
        // Stop pagination if last fetched page was empty
        if (state.lastPageIsEmpty) return null;

        // Pages are 1-based
        return state.nextIntPageKey;
      },
      fetchPage: fetchPage,
    );
  }

  Future<List<News>> fetchPage(int pageNumber) async {
    final pagination = await _newsRepository.getNews(pageNumber: pageNumber, title: title.isNotEmpty ? title : null);

    return pagination?.news ?? [];
  }

  void searchNews(String title) {
    this.title = title;
    pagingController.refresh();
  }

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }
}
