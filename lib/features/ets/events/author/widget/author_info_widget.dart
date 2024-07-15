// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/ets/events/author/author_info_skeleton.dart';
import 'package:notredame/features/ets/events/author/author_viewmodel.dart';
import 'package:notredame/features/ets/events/social/models/social_link.dart';
import 'package:notredame/features/ets/events/social/social_links_card.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/utils.dart';

class AuthorInfoWidget extends ViewModelWidget<AuthorViewModel> {
  const AuthorInfoWidget({super.key});

  @override
  Widget build(BuildContext context, AuthorViewModel model) {
    final author = model.author;

    List<SocialLink> socialLinks = [];
    if (author != null) {
      socialLinks = [
        if (author.email != null)
          SocialLink(id: 0, name: 'Email', link: author.email!),
        if (author.facebookLink != null)
          SocialLink(id: 1, name: 'Facebook', link: author.facebookLink!),
        if (author.instagramLink != null)
          SocialLink(id: 2, name: 'Instagram', link: author.instagramLink!),
        if (author.tikTokLink != null)
          SocialLink(id: 3, name: 'TikTok', link: author.tikTokLink!),
        if (author.xLink != null)
          SocialLink(id: 4, name: 'X', link: author.xLink!),
        if (author.redditLink != null)
          SocialLink(id: 5, name: 'Reddit', link: author.redditLink!),
        if (author.discordLink != null)
          SocialLink(id: 6, name: 'Discord', link: author.discordLink!),
        if (author.linkedInLink != null)
          SocialLink(id: 7, name: 'LinkedIn', link: author.linkedInLink!),
      ];
    }

    return Padding(
      padding: const EdgeInsets.only(top: 76),
      child: model.isBusy
          ? AuthorInfoSkeleton()
          : SizedBox(
              width: double.infinity,
              child: Card(
                color: Utils.getColorByBrightnessNullable(
                    context, AppTheme.newsSecondaryColor, null),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(32, 64, 32, 16),
                  child: Column(
                    children: [
                      if (author?.organization != null ||
                          author?.organization != "")
                        Text(
                          author?.organization ?? "",
                          style: const TextStyle(fontSize: 26),
                        ),
                      if (author?.organization != null &&
                          author?.organization != "")
                        const SizedBox(height: 8),
                      if (author?.profileDescription != null &&
                          author?.profileDescription != "")
                        Text(
                          author?.profileDescription ?? "",
                          style: TextStyle(
                            color: Utils.getColorByBrightness(
                                context,
                                AppTheme.etsDarkGrey,
                                AppTheme.newsSecondaryColor),
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      if (author?.profileDescription != null &&
                          author?.profileDescription != "")
                        const SizedBox(height: 8),
                      IconButton(
                        onPressed: () async {
                          await showModalBottomSheet(
                            isDismissible: true,
                            enableDrag: true,
                            isScrollControlled: true,
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10)),
                            ),
                            builder: (context) =>
                                SocialLinks(socialLinks: socialLinks),
                          );
                        },
                        icon: FaIcon(
                          FontAwesomeIcons.link,
                          color: Utils.getColorByBrightness(
                              context,
                              AppTheme.newsAccentColorLight,
                              AppTheme.newsAccentColorDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
