// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shimmer/shimmer.dart';

// Project imports:
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';

class NewsCardSkeleton extends StatelessWidget {
  const NewsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerEffect(context),
                const SizedBox(height: 8),
                _shimmerTextEffect(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerEffect(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.theme.appColors.backgroundAlt,
      highlightColor: context.theme.appColors.shimmerHighlight,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _shimmerTextEffect(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.theme.appColors.backgroundAlt,
      highlightColor: context.theme.appColors.shimmerHighlight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 20.0,
            decoration: BoxDecoration(
              color: AppPalette.grey.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 100,
                height: 20.0,
                decoration: BoxDecoration(
                  color: AppPalette.grey.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Container(
                width: 60,
                height: 20.0,
                decoration: BoxDecoration(
                  color: AppPalette.grey.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
