// Flutter imports:
import 'package:ets_api_clients/models.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:notredame/features/ets/events/author/widget/author_info_widget.dart';
import 'package:notredame/features/ets/events/author/widget/avatar_widget.dart';
import 'package:notredame/features/ets/events/author/widget/back_button_widget.dart';
import 'package:notredame/features/ets/events/author/widget/no_more_news_card_widget.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/ets/events/author/author_viewmodel.dart';
import 'package:notredame/features/app/widgets/base_scaffold.dart';
import 'package:notredame/features/ets/events/news/widgets/news_card.dart';
import 'package:notredame/features/ets/events/news/widgets/news_card_skeleton.dart';

class AuthorView extends StatelessWidget {
  final String authorId;

  const AuthorView({required this.authorId, super.key});

  Widget _buildErrorWidget(PagingController<int, News> pagingController, BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AuthorViewModel>.reactive(
      viewModelBuilder: () => AuthorViewModel(
        authorId: authorId,
        appIntl: AppIntl.of(context)!,
      ),
      onViewModelReady: (model) {
        model.fetchAuthorData();
        model.pagingController.addStatusListener((status) {
          if (status == PagingStatus.subsequentPageError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppIntl.of(context)!.news_error_not_found),
                action: SnackBarAction(
                  label: AppIntl.of(context)!.retry,
                  onPressed: () => model.pagingController.retryLastFailedRequest(),
                ),
              ),
            );
          }
        });
      },
      builder: (context, model, child) {
        return BaseScaffold(
          showBottomBar: false,
          body: RefreshIndicator(
            onRefresh: () => Future.sync(() => model.pagingController.refresh()),
            child: Theme(
              data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
              child: Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Stack(
                      children: [
                        BackButtonWidget(),
                        AuthorInfoWidget(),
                        AvatarWidget(),
                      ],
                    ),
                    Expanded(
                      child: PagedListView<int, News>(
                        key: const Key("pagedListView"),
                        pagingController: model.pagingController,
                        padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                        builderDelegate: PagedChildBuilderDelegate<News>(
                          itemBuilder: (context, item, index) => NewsCard(item),
                          firstPageProgressIndicatorBuilder: (context) => NewsCardSkeleton(),
                          newPageProgressIndicatorBuilder: (context) => NewsCardSkeleton(),
                          noMoreItemsIndicatorBuilder: (context) => const NoMoreNewsCardWidget(),
                          firstPageErrorIndicatorBuilder: (context) => _buildErrorWidget(model.pagingController, context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
