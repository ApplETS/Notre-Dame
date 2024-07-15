// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

// Project imports:
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/ets/events/api-client/models/news.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/locator.dart';

// Package imports:

class NewsCard extends StatefulWidget {
  final News news;

  const NewsCard(this.news, {super.key});

  @override
  _NewsCardState createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  final NavigationService _navigationService = locator<NavigationService>();

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('fr', timeago.FrShortMessages());
    return GestureDetector(
      onTap: () => _navigationService.pushNamed(RouterPaths.newsDetails,
          arguments: widget.news),
      child: Card(
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
                  Hero(
                      tag: 'news_image_id_${widget.news.id}',
                      child: _buildImage(widget.news.imageUrl)),
                  const SizedBox(height: 8),
                  _buildTitleAndTime(widget.news, context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? imageUrl) {
    var isLoaded = false;
    if (imageUrl != null && imageUrl != "") {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Image.network(
          imageUrl == ""
              ? "https://www.shutterstock.com/image-vector/no-photo-thumbnail-graphic-element-600nw-2311073121.jpg"
              : imageUrl,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            isLoaded = frame != null;
            return child;
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (isLoaded && loadingProgress == null) {
              return child;
            } else {
              return _shimmerEffect();
            }
          },
        ),
      );
    }

    return const SizedBox();
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
          timeago.format(news.publicationDate,
              locale: AppIntl.of(context)!.localeName),
          style: textStyle,
        ),
      ],
    );
  }
}
