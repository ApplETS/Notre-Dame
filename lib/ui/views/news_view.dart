// Flutter imports:
import 'package:ets_api_clients/models.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<NewsViewModel>.reactive(
          viewModelBuilder: () => NewsViewModel(intl: AppIntl.of(context)!),
          onModelReady: (model) {
            model.pagingController.addStatusListener((status) {
              if (status == PagingStatus.subsequentPageError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Something went wrong while fetching a new page.',
                    ),
                    action: SnackBarAction(
                      label: 'Retry',
                      onPressed: () =>
                          model.pagingController.retryLastFailedRequest(),
                    ),
                  ),
                );
              }
            });
          },
          builder: (context, model, child) {
            return RefreshIndicator(
                onRefresh: () => Future.sync(
                      () => model.pagingController.refresh(),
                    ),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(canvasColor: Colors.transparent),
                  child: PagedListView<int, News>(
                    pagingController: model.pagingController,
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                    builderDelegate: PagedChildBuilderDelegate<News>(
                      itemBuilder: (context, item, index) => NewsCard(item),
                      firstPageProgressIndicatorBuilder: (context) =>
                          _buildSkeletonLoader(),
                      newPageProgressIndicatorBuilder: (context) =>
                          NewsCardSkeleton(),
                      noMoreItemsIndicatorBuilder: (context) =>
                          _buildNoMoreNewsCard(),
                      firstPageErrorIndicatorBuilder: (context) =>
                          _buildError(model.pagingController),
                    ),
                  ),
                ));
          });

  Widget _buildSkeletonLoader() {
    final Widget skeleton = NewsCardSkeleton();
    return Column(children: [
      for (var i = 0; i < _nbSkeletons; i++) skeleton,
    ]);
  }

  Widget _buildNoMoreNewsCard() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ),
        const SizedBox(height: 16),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                  child: Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.check, color: Colors.blue, size: 40),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("You're all set!",
                                  style: TextStyle(fontSize: 24)),
                              SizedBox(height: 16),
                              Text(
                                'You have reached the end of the news list. Come back another time for more news!',
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(PagingController<int, News> pagingController) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 80,
                ),
                child: Text(
                  AppIntl.of(context)!.news_error_not_found_title,
                  style: const TextStyle(
                      fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 70,
                ),
                child: Text(
                  AppIntl.of(context)!.news_error_not_found,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
              Flexible(
                child: ElevatedButton(
                  onPressed: () {
                    pagingController.retryLastFailedRequest();
                  },
                  child: Text(AppIntl.of(context)!.retry),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
