// Flutter imports:
import 'package:ets_api_clients/models.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/core/utils/utils.dart';
import 'package:notredame/ui/utils/app_theme.dart';
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
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;
  String _query = "";

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset >= 200) {
        if (!_showBackToTopButton) {
          setState(() {
            _showBackToTopButton = true;
          });
        }
      } else {
        if (_showBackToTopButton) {
          setState(() {
            _showBackToTopButton = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<NewsViewModel>.reactive(
        viewModelBuilder: () => NewsViewModel(),
        onViewModelReady: (model) {
          model.pagingController.addStatusListener((status) {
            if (status == PagingStatus.subsequentPageError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppIntl.of(context)!.news_error_not_found,
                  ),
                  action: SnackBarAction(
                    label: AppIntl.of(context)!.retry,
                    onPressed: () =>
                        model.pagingController.retryLastFailedRequest(),
                  ),
                ),
              );
            }
          });
        },
        builder: (context, model, child) {
          return Scaffold(
              floatingActionButton: _showBackToTopButton
                  ? FloatingActionButton(
                      shape: const CircleBorder(),
                      backgroundColor: AppTheme.appletsPurple,
                      foregroundColor: Colors.white,
                      onPressed: () {
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Icon(Icons.arrow_upward),
                    )
                  : null,
              body: RefreshIndicator(
                  onRefresh: () => Future.sync(
                        () => model.pagingController.refresh(),
                      ),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(canvasColor: Colors.transparent),
                    child: Column(
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(
                                top: 8, left: 4, right: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                      height: 52,
                                      child: TextField(
                                        decoration: InputDecoration(
                                            hintText:
                                                AppIntl.of(context)!.search,
                                            filled: true,
                                            fillColor:
                                                Utils.getColorByBrightness(
                                                    context,
                                                    AppTheme.lightThemeAccent,
                                                    Theme.of(context)
                                                        .cardColor),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.fromLTRB(
                                                    16, 8, 16, 0)),
                                        style: const TextStyle(fontSize: 18),
                                        onEditingComplete: () =>
                                            {model.searchNews(_query)},
                                        onChanged: (query) {
                                          _query = query;
                                        },
                                      )),
                                ),
                              ],
                            )),
                        Expanded(
                          child: PagedListView<int, News>(
                            key: const Key("pagedListView"),
                            pagingController: model.pagingController,
                            scrollController: _scrollController,
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                            builderDelegate: PagedChildBuilderDelegate<News>(
                              itemBuilder: (context, item, index) =>
                                  NewsCard(item),
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
                        ),
                      ],
                    ),
                  )));
        },
      );

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
                  child: Row(
                    children: [
                      const Icon(Icons.check, color: Colors.blue, size: 40),
                      const SizedBox(width: 16),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppIntl.of(context)!.news_no_more_card_title,
                                style: const TextStyle(fontSize: 24)),
                            const SizedBox(height: 16),
                            Text(
                              AppIntl.of(context)!.news_no_more_card,
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                    ],
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
