import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:notredame/core/models/news.dart';

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
                _buildImage(widget.news),
                const SizedBox(height: 8),
                _shimmerTextEffect(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(News news) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: _shimmerEffect(),
    );
  }

  Widget _shimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: Container(
        height: 200, // Specify a fixed height for the shimmer effect
        color: Colors.grey,
      ),
    );
  }

  Widget _shimmerTextEffect(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 20.0,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 100,
                height: 20.0,
                color: Colors.white,
              ),
              Container(
                width: 60,
                height: 20.0,
                color: Colors.white,
              ),
            ],
          ),
        ],
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
        .resolve(ImageConfiguration())
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
