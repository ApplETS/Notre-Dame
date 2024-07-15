// Flutter imports:
import 'package:flutter/material.dart';
import 'package:notredame/features/ets/events/api-client/models/news.dart';

// Package imports:
import 'package:shimmer/shimmer.dart';
import 'package:notredame/utils/app_theme.dart';

// Project imports:

Widget newsImageSection(News news) {
  var isLoaded = false;
  return Hero(
    tag: 'news_image_id_${news.id}',
    child: (news.imageUrl == null || news.imageUrl == "")
        ? const SizedBox.shrink()
        : Image.network(
            news.imageUrl!,
            fit: BoxFit.cover,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              isLoaded = frame != null;
              return child;
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (isLoaded && loadingProgress == null) {
                return child;
              } else {
                return const ShimmerEffect();
              }
            },
          ),
  );
}

class ShimmerEffect extends StatelessWidget {
  const ShimmerEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).brightness == Brightness.light
          ? AppTheme.lightThemeBackground
          : AppTheme.darkThemeBackground,
      highlightColor: Theme.of(context).brightness == Brightness.light
          ? AppTheme.lightThemeAccent
          : AppTheme.darkThemeAccent,
      child: Container(
        height: 200,
        color: Colors.grey,
      ),
    );
  }
}
