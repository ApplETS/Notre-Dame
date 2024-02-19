// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Project imports:
import 'package:notredame/core/constants/report_news.dart';
import 'package:notredame/core/models/socialLink.dart';
import 'package:notredame/core/utils/utils.dart';
import 'package:notredame/core/viewmodels/quick_links_viewmodel.dart';
import 'package:notredame/core/viewmodels/web_link_card_viewmodel.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:stacked/stacked.dart';

class SocialLinks extends StatefulWidget {
  final bool showHandle;
  final List<SocialLink> socialLinks;

  const SocialLinks(
      {Key? key, required this.socialLinks, this.showHandle = true})
      : super(key: key);

  @override
  _SocialLinksState createState() => _SocialLinksState();
}

class _SocialLinksState extends State<SocialLinks> {
  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<WebLinkCardViewModel>.reactive(
          viewModelBuilder: () => WebLinkCardViewModel(),
          builder: (context, model, child) {
            return SizedBox(
                height: MediaQuery.of(context).size.height * 0.30,
                child: Column(
                  children: [
                    if (widget.showHandle) _buildHandle(context),
                    _buildTitle(context),
                    _buildSocialButtons(widget.socialLinks, model),
                  ],
                ));
          });

  Widget _buildHandle(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Utils.getColorByBrightness(
          context,
          AppTheme.lightThemeBackground,
          AppTheme.darkThemeBackground,
        ),
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
            decoration: const BoxDecoration(
                color: Colors.grey,
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
        color: Utils.getColorByBrightness(
          context,
          AppTheme.lightThemeBackground,
          AppTheme.darkThemeBackground,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 20, 20, 20),
          child: Text(
            AppIntl.of(context)!.news_author_join_us,
            style: Theme.of(context).textTheme.headline5,
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        children: rows,
      ),
    );
  }

  Widget _buildSocialButton(SocialLink link, WebLinkCardViewModel model) {
    return IconButton(
      icon: link.image,
      onPressed: () => model.onLinkClicked(link, Theme.of(context).brightness),
    );
  }
}
