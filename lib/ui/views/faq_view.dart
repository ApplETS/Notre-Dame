// FLUTTER / DART / THIRD-PARTIES
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
import 'package:notredame/core/services/preferences_service.dart';

// CONSTANTS
import 'package:notredame/core/constants/faq.dart';
import 'package:notredame/core/constants/preferences_flags.dart';

// UTILS
import 'package:notredame/core/utils/utils.dart';
import 'package:notredame/ui/utils/app_theme.dart';

class FaqView extends StatefulWidget {
  @override
  State<FaqView> createState() => _FaqViewState();
}

class _FaqViewState extends State<FaqView> {
  final Faq faq = Faq();
  
  final PreferencesService _preferencesService = locator<PreferencesService>();

  final PageController _pageController = PageController(
    viewportFraction: 0.80,
  );
  
  @override
  Widget build(BuildContext context) =>
    ViewModelBuilder<FaqViewModel>.reactive(
      viewModelBuilder: () => FaqViewModel(intl: AppIntl.of(context)),
      builder: (context, model, child) {
        final bool isLightMode =
            Theme.of(context).brightness == Brightness.light;
        return Scaffold(
          backgroundColor: Utils.getColorByBrightness(
                context, AppTheme.etsLightRed, AppTheme.primaryDark),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              getTitle(),
              getSubtitle(AppIntl.of(context).questions_and_answers),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: faq.questions.length,
                  itemBuilder: (context, index) {
                    final question = faq.questions[index];

                    return getQuestionCard(
                      question.title["en"],
                      question.description["en"],
                    );
                  },
                  pageSnapping: false,
                  physics: const BouncingScrollPhysics(), // Optional: Add bounce effect
                ),
              ),
              getSubtitle(AppIntl.of(context).actions),
              Expanded(
                child: ListView.builder(
                  itemCount: faq.actions.length,
                  itemBuilder: (context, index) {
                    final action = faq.actions[index];
                    // TODO
                    final lang = _preferencesService.getString(PreferencesFlag.locale);
                    print(lang);
                    
                    return getActionCard(
                      action.title["fr"], 
                      action.description["fr"],
                      ActionType.email, // TODO : action.type
                      action.link,
                      action.iconName,
                      action.iconColor,
                      action.circleColor,
                      context,
                    );
                  },
                ),
              ),
              const SizedBox(height: 10.0)
            ],
          ),
        );
      },
    );

  Padding getTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 60.0, bottom: 20.0),
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
      padding: const EdgeInsets.only(left: 18.0, top: 10.0),
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
      padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8, // Set the desired width
        child: ElevatedButton(
          onPressed: () {},
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
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
                            color: getTextColor(context),
                          ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                            fontSize: 16,
                            color: getTextColor(context),
                          ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),
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
      String iconName,
      Color iconColor,
      Color circleColor,
      BuildContext context,
    ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 15.0),
      child: ElevatedButton(
        onPressed: () {
          if (type == ActionType.webview) {
            // TODO : Implement webview
          } else if (type == ActionType.email) {
            // TODO : Implement email
            
          }
        },
        style: ButtonStyle(
            shape:
                MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        )),
        child: getActionCardInfo(
          context,
          title,
          description,
          Icons.design_services,
          iconColor,
          circleColor,
        ),
      ),
    );
  }

  Row getActionCardInfo(BuildContext context, String title, String description,
      IconData icon, Color iconColor, Color circleColor) {
    return Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: circleColor,
              radius: 25,
              child: Icon(icon, color: iconColor),
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
                    color: getTextColor(context),
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 10.0),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                    fontSize: 16,
                    color: getTextColor(context),
                  ),
                  textAlign: TextAlign.left,
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.black
        : Colors.white;
  }
}
