// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/core/viewmodels/news_viewmodel.dart';
import 'package:notredame/ui/widgets/news_card.dart';
import 'package:notredame/ui/widgets/news_card_skeleton.dart';

class NewsView extends StatefulWidget {
  @override
  State<NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<NewsViewModel>.reactive(
          viewModelBuilder: () => NewsViewModel(intl: AppIntl.of(context)!),
          builder: (context, model, child) {
            return RefreshIndicator(
                onRefresh: model.refresh,
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(canvasColor: Colors.transparent),
                  child: model.isLoadingEvents
                      ? _buildSkeletonLoader()
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                          children:
                              model.news.map((news) => NewsCard(news)).toList(),
                        ),
                ));
          });

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) => NewsCardSkeleton(),
    );
  }
}
