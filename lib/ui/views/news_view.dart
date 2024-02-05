import 'package:flutter/material.dart';
import 'package:notredame/ui/widgets/news_card.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/ui/widgets/news_card_skeleton.dart';

// VIEW-MODEL
import 'package:notredame/core/viewmodels/news_viewmodel.dart';

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
              child: Theme(
                data:
                    Theme.of(context).copyWith(canvasColor: Colors.transparent),
                child: model.isLoadingEvents
                    ? _buildSkeletonLoader()
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                        children:
                            model.news.map((news) => NewsCard(news)).toList()),
              ),
              onRefresh: () => model.refresh(),
            );
          });

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) => const NewsCardSkeleton(),
    );
  }
}
