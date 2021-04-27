// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// CONSTANT
import 'package:notredame/core/constants/router_paths.dart';

// MODEL
import 'package:notredame/core/models/quick_link.dart';

// SERVICE
import 'package:notredame/core/services/navigation_service.dart';

// OTHER
import 'package:notredame/locator.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/core/utils/utils.dart';

class WebLinkCard extends StatelessWidget {
  final QuickLink _links;

  /// used to redirect on the security.
  final NavigationService _navigationService = locator<NavigationService>();

  WebLinkCard(this._links);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3.1,
      height: 130,
      child: Card(
        elevation: 4.0,
        child: InkWell(
          onTap: () => _onLinkClicked(_links.link, context),
          splashColor: AppTheme.etsLightRed.withAlpha(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  flex: 40,
                  child: Image.asset(_links.image, color: AppTheme.etsLightRed),
                ),
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    _links.name,
                    style: const TextStyle(color: Colors.red, fontSize: 18.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// used to open a website or the security view
  void _onLinkClicked(String link, BuildContext context) {
    if (link == 'security') {
      _navigationService.pushNamed(RouterPaths.security);
    } else {
      Utils.launchURL(link, AppIntl.of(context));
    }
  }
}
