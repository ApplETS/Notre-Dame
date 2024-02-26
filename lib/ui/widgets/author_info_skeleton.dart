// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shimmer/shimmer.dart';

// Project imports:
import 'package:notredame/core/utils/utils.dart';
import 'package:notredame/ui/utils/app_theme.dart';

class AuthorInfoSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(32, 64, 32, 16),
            child: Column(
              children: [
                _shimmerTextEffect(context, 26), // Title
                const SizedBox(height: 10),
                _shimmerTextEffect(context, 16), // Description
                const SizedBox(height: 10),
                _buildButtons(context), // Buttons
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerTextEffect(BuildContext context, double height) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).brightness == Brightness.light
          ? AppTheme.lightThemeBackground
          : AppTheme.darkThemeBackground,
      highlightColor: Theme.of(context).brightness == Brightness.light
          ? AppTheme.lightThemeAccent
          : AppTheme.darkThemeAccent,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _shimmerTextEffect(context, 40), // Button
        ),
        const SizedBox(width: 10),
        _shimmerIconButton(context), // IconButton
      ],
    );
  }

  Widget _shimmerIconButton(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).brightness == Brightness.light
          ? AppTheme.lightThemeBackground
          : AppTheme.darkThemeBackground,
      highlightColor: Theme.of(context).brightness == Brightness.light
          ? AppTheme.lightThemeAccent
          : AppTheme.darkThemeAccent,
      child: IconButton(
        onPressed: () {}, // Placeholder onPressed function
        icon: Icon(
          Icons.link,
          color: Utils.getColorByBrightness(
            context,
            AppTheme.newsAccentColorLight,
            AppTheme.newsAccentColorDark,
          ),
        ),
      ),
    );
  }
}

class AvatarSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: SizedBox(
          width: 120,
          height: 120,
          child: ClipOval(
            child: Shimmer.fromColors(
              baseColor: Theme.of(context).brightness == Brightness.light
                  ? AppTheme.lightThemeBackground
                  : AppTheme.darkThemeBackground,
              highlightColor: Theme.of(context).brightness == Brightness.light
                  ? AppTheme.lightThemeAccent
                  : AppTheme.darkThemeAccent,
              child: Container(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
