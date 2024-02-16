// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/core/managers/news_repository.dart';
import 'package:notredame/core/models/news.dart';
import 'package:notredame/locator.dart';
import 'package:stacked/stacked.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// Project imports:
import 'package:notredame/core/viewmodels/news_viewmodel.dart';
import 'package:notredame/ui/widgets/news_card.dart';
import 'package:notredame/ui/widgets/news_card_skeleton.dart';

class NewsView extends StatefulWidget {
  @override
  State<NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> {
  static const int _nbSkeletons = 3;
  static const _pageSize = 3;

  final NewsRepository _newsRepository = locator<NewsRepository>();

  final PagingController<int, News> pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });
    pagingController.addStatusListener((status) {
      if (status == PagingStatus.subsequentPageError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Something went wrong while fetching a new page.',
            ),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => pagingController.retryLastFailedRequest(),
            ),
          ),
        );
      }
    });
    super.initState();
  }

  Future<void> fetchPage(int pageNumber) async {
    try {
      final newItems = await _newsRepository.getNews(
              pageNumber: pageNumber, fromCacheOnly: true) ??
          [];
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageNumber + newItems.length;
        pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<NewsViewModel>.reactive(
          viewModelBuilder: () => NewsViewModel(intl: AppIntl.of(context)!),
          builder: (context, model, child) {
            return RefreshIndicator(
                onRefresh: () => Future.sync(
                      () => pagingController.refresh(),
                    ),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(canvasColor: Colors.transparent),
                  child: PagedListView<int, News>(
                    pagingController: pagingController,
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                    builderDelegate: PagedChildBuilderDelegate<News>(
                      itemBuilder: (context, item, index) => NewsCard(item),
                      firstPageProgressIndicatorBuilder: (context) =>
                          _buildSkeletonLoader(),
                      newPageProgressIndicatorBuilder: (context) =>
                          NewsCardSkeleton(),
                      noItemsFoundIndicatorBuilder: (_) =>
                          NoItemsFoundIndicator(),
                      noMoreItemsIndicatorBuilder: (_) =>
                          NoMoreItemsIndicator(),
                    ),
                  ),
                ));
          });

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      itemCount: _nbSkeletons,
      itemBuilder: (context, index) => NewsCardSkeleton(),
    );
  }
}
