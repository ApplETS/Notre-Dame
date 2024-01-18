// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;

// MODEL
import 'package:notredame/core/models/news.dart';

class NewsCard extends StatelessWidget {
  final News news;

  const NewsCard(this.news);

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('fr', timeago.FrShortMessages());
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      key: UniqueKey(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(news),
                const SizedBox(height: 8),
                _buildTitleAndTime(news, context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(News news) {
    if (news.image == null) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Image.network(
        news.image,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTitleAndTime(News news, BuildContext context) {
    final TextStyle textStyle =
        Theme.of(context).textTheme.titleMedium.copyWith(
              fontSize: 16,
            );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            news.title,
            style: textStyle,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          timeago.format(news.date, locale: AppIntl.of(context).localeName),
          style: textStyle,
        ),
      ],
    );
  }
}
