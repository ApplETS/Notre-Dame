// FLUTTER / DART / THIRD-PARTIES
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:notredame/locator.dart';
import 'package:stacked/stacked.dart';

// UTILS
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// VIEWMODEL
import 'package:notredame/core/viewmodels/faq_viewmodel.dart';

// MODELS
import 'package:notredame/core/models/faq_actions.dart';

// SERVICES
import 'package:notredame/core/services/launch_url_service.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/navigation_service.dart';

// CONSTANTS
import 'package:notredame/core/constants/faq.dart';
import 'package:notredame/core/constants/app_info.dart';

// UTILS
import 'package:notredame/core/utils/utils.dart';
import 'package:notredame/ui/utils/app_theme.dart';

class FaqView extends StatefulWidget {
  @override
  State<FaqView> createState() => _FaqViewState();
}

class _FaqViewState extends State<FaqView> {
  final Faq faq = Faq();
  
  final LaunchUrlService _launchUrlService = locator<LaunchUrlService>();

  final NavigationService _navigationService = locator<NavigationService>();
  
  @override
  Widget build(BuildContext context) =>
    ViewModelBuilder<FaqViewModel>.reactive(
      viewModelBuilder: () => FaqViewModel(),
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: Utils.getColorByBrightness(
                context, AppTheme.etsLightRed, AppTheme.primaryDark),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              getTitle(),
              getSubtitle(AppIntl.of(context).questions_and_answers),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 250.0,
                  ),
                  items: faq.questions.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final question = faq.questions[index];

                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 240, 238, 238),
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          ),
                          child: getQuestionCard(
                            question.title[model.locale.languageCode],
                            question.description[model.locale.languageCode],
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
              getSubtitle(AppIntl.of(context).actions),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 1.0),
                  itemCount: faq.actions.length,
                  itemBuilder: (context, index) {
                    final action = faq.actions[index];

                    return getActionCard(
                      action.title[model.locale.languageCode], 
                      action.description[model.locale.languageCode],
                      action.type,
                      action.link,
                      action.iconName,
                      action.iconColor,
                      action.circleColor,
                      context,
                      model
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );

  Padding getTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 60.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                AppIntl.of(context).need_help,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline5.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
  }

  Padding getSubtitle(String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(left: 18.0, top: 18.0, bottom: 10.0),
      child: Text(
          subtitle,
          style: Theme.of(context).textTheme.headline5.copyWith(
            color: Colors.white,
          ),
        ),
    );
  }

  Padding getQuestionCard(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20.0),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding getActionCard(
      String title, 
      String description, 
      ActionType type, 
      String link,
      IconData iconName,
      Color iconColor,
      Color circleColor,
      BuildContext context,
      FaqViewModel model
    ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 15.0),
      child: ElevatedButton(
        onPressed: () {
          if (type.name == ActionType.webview.name) {
            openWebview(model, link);
          } else if (type.name == ActionType.email.name) {
            openMail(model, link);
          }
        },
        style: ButtonStyle(
          elevation: MaterialStateProperty.all<double>(8.0),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        )),
        child: getActionCardInfo(
          context,
          title,
          description,
          iconName,
          iconColor,
          circleColor,
        ),
      ),
    );
  }

  Row getActionCardInfo(BuildContext context, String title, String description,
      IconData iconName, Color iconColor, Color circleColor) {
    return Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: circleColor,
              radius: 25,
              child: Icon(iconName, color: iconColor),
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 0, 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                    fontSize: 18,
                    color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 10.0),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                    fontSize: 16,
                    color:  Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                  ),
                  textAlign: TextAlign.justify,
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Future<void> openWebview(FaqViewModel model, String link) async {
     model.launchWebsite(link, Theme.of(context).brightness);
  }

  Future<void> openMail(FaqViewModel model, String addressEmail) async {
    var email = "";
    if (addressEmail == AppInfo.email) {
      email =
        model.mailtoStr(addressEmail, AppIntl.of(context).email_subject);
    } else {
      email =
        model.mailtoStr(addressEmail, "");
    }
    
    final urlLaunchable = await _launchUrlService.canLaunch(email);

    if (urlLaunchable) {
      await _launchUrlService.launch(email);
    } else {
      locator<AnalyticsService>().logError("login_view", "Cannot send email.");
    }
  }
}
