// Flutter imports:
import 'package:flutter/material.dart';
import 'dart:convert';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:ets_api_clients/models.dart';

// Project imports:
import 'package:notredame/ui/utils/app_theme.dart';

class NewsCard extends StatefulWidget {
  final News news;

  const NewsCard(this.news, {Key? key}) : super(key: key);

  @override
  _NewsCardState createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool _isImageLoaded = false;

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
                _buildImage(widget.news.imageThumbnail),
                const SizedBox(height: 8),
                _buildTitleAndTime(widget.news, context)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String? image) {
    if (image == null || image == "") {
      return const SizedBox();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: _imageFromBase64String(image),
    );
  }

  Image _imageFromBase64String(String base64String) {
    return Image.memory(base64Decode(base64String));
  }

  Widget _shimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).brightness == Brightness.light
          ? AppTheme.lightThemeBackground
          : AppTheme.darkThemeBackground,
      highlightColor: Theme.of(context).brightness == Brightness.light
          ? AppTheme.lightThemeAccent
          : AppTheme.darkThemeAccent,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildTitleAndTime(News news, BuildContext context) {
    final TextStyle textStyle =
        Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 16);

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
          timeago.format(news.createdAt,
              locale: AppIntl.of(context)!.localeName),
          style: textStyle,
        ),
      ],
    );
  }
}
