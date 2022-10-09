// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// UTILS
import 'package:notredame/core/utils/utils.dart';

// VIEW MODEL
import 'package:notredame/core/viewmodels/outage_viewmodel.dart';

//UTILS
import 'package:notredame/ui/utils/app_theme.dart';

//CONSTANT
import 'package:notredame/core/constants/urls.dart';

class OutageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ViewModelBuilder<
          OutageViewModel>.nonReactive(
      viewModelBuilder: () => OutageViewModel(),
      onModelReady: (OutageViewModel model) {},
      builder: (context, model, child) => Scaffold(
            backgroundColor: Utils.getColorByBrightness(
                context, AppTheme.etsLightRed, AppTheme.primaryDark),
            body: Stack(
              children: [
                SafeArea(
                  minimum: const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: model.getImagePlacement(context),
                      ),
                      Hero(
                          tag: 'ets_logo',
                          child: Image.asset(
                            "assets/animations/outage.gif",
                            excludeFromSemantics: true,
                            width: 500,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.white
                                    : AppTheme.etsLightRed,
                          )),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(height: model.getTextPlacement(context)),
                      Text(
                        AppIntl.of(context).service_outage,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      SizedBox(height: model.getButtonPlacement(context)),
                      ElevatedButton(
                        onPressed: () {
                          model.tapRefreshButton(context);
                        },
                        child: Text(
                          AppIntl.of(context).service_outage_refresh,
                          style: const TextStyle(fontSize: 17),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: model.getContactTextPlacement(context),
                              child: Text(
                                AppIntl.of(context).service_outage_contact,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                    icon: const FaIcon(
                                      FontAwesomeIcons.earthAmericas,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => Utils.launchURL(
                                        Urls.clubWebsite, AppIntl.of(context))),
                                IconButton(
                                    icon: const FaIcon(
                                      FontAwesomeIcons.github,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => Utils.launchURL(
                                        Urls.clubGithub, AppIntl.of(context))),
                                IconButton(
                                    icon: const FaIcon(
                                      Icons.mail_outline,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => Utils.launchURL(
                                        Urls.clubEmail, AppIntl.of(context))),
                                IconButton(
                                    icon: const FaIcon(
                                      FontAwesomeIcons.discord,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => Utils.launchURL(
                                        Urls.clubDiscord, AppIntl.of(context))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => model.triggerTap(context),
                      child: Container(
                        width: 60,
                        height: 60,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ));
}
