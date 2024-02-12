// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

// Project imports:
import 'package:notredame/core/models/news.dart';
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
                _buildImage(widget.news.image),
                const SizedBox(height: 8),
                _buildTitleAndTime(widget.news, context)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String image) {
    if (image == "") {
      return const SizedBox();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: _isImageLoaded
          ? Image.network(image, fit: BoxFit.cover)
          : _shimmerEffect(),
    );
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
          timeago.format(news.date, locale: AppIntl.of(context)!.localeName),
          style: textStyle,
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _preloadImage();
  }

  void _preloadImage() {
    Image.network(widget.news.image)
        .image
        // ignore: use_named_constants
        .resolve(const ImageConfiguration())
        .addListener(
          ImageStreamListener(
            (ImageInfo image, bool synchronousCall) {
              if (mounted) {
                setState(() {
                  _isImageLoaded = true;
                });
              }
            },
            onError: (exception, stackTrace) {
              // Handle image load error
            },
          ),
        );
  }
}
