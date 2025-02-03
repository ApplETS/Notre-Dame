// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/theme/app_theme.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/ets/events/social/models/social_link.dart';
import 'package:notredame/features/ets/quick-link/widgets/web_link_card_viewmodel.dart';

class SocialLinks extends StatefulWidget {
  final bool showHandle;
  final List<SocialLink> socialLinks;

  const SocialLinks(
      {super.key, required this.socialLinks, this.showHandle = true});

  @override
  State<SocialLinks> createState() => _SocialLinksState();
}

class _SocialLinksState extends State<SocialLinks> {
  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<WebLinkCardViewModel>.reactive(
          viewModelBuilder: () => WebLinkCardViewModel(),
          builder: (context, model, child) {
            return IntrinsicHeight(
                child: Container(
                    decoration: BoxDecoration(
                      color: context.theme.appColors.backgroundAlt,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40.0),
                        topRight: Radius.circular(40.0),
                      ),
                    ),
                    child: Column(
                      children: [
                        if (widget.showHandle) _buildHandle(context),
                        _buildTitle(context),
                        _buildSocialButtons(widget.socialLinks, model),
                      ],
                    )));
          });

  Widget _buildHandle(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.appColors.modalTitle,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Container(
            height: 5,
            width: 50,
            decoration: BoxDecoration(
                color: context.theme.appColors.modalHandle,
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: context.theme.appColors.modalTitle,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 20, 20, 20),
          child: Text(
            AppIntl.of(context)!.news_author_join_us,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButtons(
      List<SocialLink> socialLinks, WebLinkCardViewModel model) {
    // Define the desired order of social links
    final List<String> desiredOrder = [
      'email',
      'facebook',
      'instagram',
      'tiktok',
      'x',
      'reddit',
      'discord',
      'linkedin'
    ];

    // Sort the socialLinks list based on the desired order
    socialLinks.sort((link, otherLink) => desiredOrder
        .indexOf(link.name)
        .compareTo(desiredOrder.indexOf(otherLink.name)));

    final List<Widget> socialButtons = [];

    // Map SocialLinks to corresponding icons and build buttons for existing links
    for (final SocialLink link in socialLinks) {
      final Widget button = _buildSocialButton(link, model);
      socialButtons.add(button);
    }

    // Build rows of buttons with a maximum of 4 buttons per row
    final List<Widget> rows = [];
    for (int i = 0; i < socialButtons.length; i += 4) {
      final List<Widget> rowChildren = socialButtons.sublist(
          i, i + 4 < socialButtons.length ? i + 4 : socialButtons.length);
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: rowChildren,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        children: rows,
      ),
    );
  }

  Widget _buildSocialButton(SocialLink link, WebLinkCardViewModel model) {
    return IconButton(
      icon: link.image,
      onPressed: () => model.onLinkClicked(link),
    );
  }
}
