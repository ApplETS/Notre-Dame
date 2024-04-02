// Package imports:
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stacked/stacked.dart';
import 'package:ets_api_clients/models.dart';

// Project imports:
import 'package:notredame/core/managers/news_repository.dart';
import 'package:notredame/locator.dart';

class NewsViewModel extends BaseViewModel implements Initialisable {
  /// Load the events
  final NewsRepository _newsRepository = locator<NewsRepository>();

  final PagingController<int, News> pagingController =
      PagingController(firstPageKey: 1);

  bool isLoadingEvents = false;
  String title = "";

  @override
  void initialise() {
    // This will be called when init state cycle runs
    pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });
  }

  Future<void> fetchPage(int pageNumber) async {
    try {
      final pagination = await _newsRepository.getNews(
        pageNumber: pageNumber,
        title: title != "" ? title : null,
      );
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

  void searchNews(String title) {
    this.title = title;
    pagingController.refresh();
  }
}
