// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:skeletonizer/skeletonizer.dart';

// Project imports:
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';

class AuthorInfoSkeleton extends StatelessWidget {
  const AuthorInfoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Skeletonizer(
        enabled: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(32, 64, 32, 16),
              child: Column(
                children: [
                  _skeletonizerTextEffect(context, 26), // Title
                  const SizedBox(height: 10),
                  _skeletonizerTextEffect(context, 16), // Description
                  const SizedBox(height: 10),
                  _buildButtons(context), // Buttons
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _skeletonizerTextEffect(BuildContext context, double height) {
    return Skeletonizer(
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: AppPalette.grey.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _skeletonizerTextEffect(context, 40), // Button
        ),
        const SizedBox(width: 10),
        _skeletonIconButton(context), // IconButton
      ],
    );
  }

  Widget _skeletonIconButton(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: IconButton(
        onPressed: () {}, // Placeholder onPressed function
        icon: Icon(Icons.link, color: context.theme.appColors.newsAccent),
      ),
    );
  }
}

class AvatarSkeleton extends StatelessWidget {
  const AvatarSkeleton({super.key});

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
            child: Skeletonizer(
              enabled: true,
              child: Container(
                color: AppPalette.grey.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
