// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;

// VIEW-MODEL
import 'package:notredame/core/viewmodels/news_viewmodel.dart';

// MODEL
import 'package:notredame/core/models/news.dart';

// UTILS
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/core/utils/utils.dart';

class NewsView extends StatefulWidget {
  @override
  State<NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> {
  @override
  void initState() {
    super.initState();

    timeago.setLocaleMessages('fr', timeago.FrShortMessages());
  }

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<NewsViewModel>.reactive(
          viewModelBuilder: () => NewsViewModel(intl: AppIntl.of(context)),
          builder: (context, model, child) {
            return RefreshIndicator(
              child: Theme(
                data:
                    Theme.of(context).copyWith(canvasColor: Colors.transparent),
                child: ListView(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                    children: _buildCards(model)),
              ),
              onRefresh: () => model.refresh(),
            );
          });

  List<Widget> _buildCards(NewsViewModel model) {
    final List<Widget> cards = List.empty(growable: true);

    for (final News news in model.news) {
      cards.add(_buildNewsCard(model, news));
    }

    return cards;
  }

  Widget _buildImageWithTags(News news) {
    if (news.image == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            news.image,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: Wrap(
            spacing: 8,
            children: List.generate(
              news.tags.length,
              (index) => Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: news.tags[index].color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  news.tags[index].text,
                  style: TextStyle(
                    color: _getTagTextColor(news.tags[index].color),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getTagTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Widget _buildTitleAndTime(News news, BuildContext context) {
    final TextStyle titleStyle = news.important
        ? Theme.of(context).textTheme.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )
        : Theme.of(context).textTheme.titleMedium.copyWith(
              fontWeight: FontWeight.w500,
            );

    final TextStyle timeStyle = news.important && !Utils.isDarkTheme(context)
        ? Theme.of(context).textTheme.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )
        : Theme.of(context).textTheme.bodySmall;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              news.title,
              style: titleStyle,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          timeago.format(news.date, locale: AppIntl.of(context).localeName),
          style: timeStyle,
        ),
      ],
    );
  }

  Widget _buildNewsCard(NewsViewModel model, News news) {
    return Card(
      color: news.important ? AppTheme.accent : null,
      key: UniqueKey(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageWithTags(news),
                const SizedBox(height: 8),
                _buildTitleAndTime(news, context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
