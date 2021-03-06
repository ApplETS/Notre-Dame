// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// VIEWMODELS
import 'package:notredame/core/viewmodels/choose_language_viewmodel.dart';

// OTHER
import 'package:notredame/ui/utils/app_theme.dart';

class ChooseLanguageView extends StatefulWidget {
  @override
  _ChooseLanguageViewState createState() => _ChooseLanguageViewState();
}

class _ChooseLanguageViewState extends State<ChooseLanguageView> {
  ListView languagesListView(ChooseLanguageViewModel model) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      itemCount: model.languages.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.grey[900],
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              ListTile(
                title: Text(model.languages[index]),
                trailing: Icon(
                    model.languageSelectedIndex == index ? Icons.check : null),
                onTap: () {
                  model.changeLanguage(index);
                },
              ),
            ]));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChooseLanguageViewModel>.reactive(
        viewModelBuilder: () =>
            ChooseLanguageViewModel(intl: AppIntl.of(context)),
        builder: (context, model, child) => Scaffold(
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? AppTheme.etsLightRed
                  : AppTheme.primaryDark,
              body: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Icon(
                      Icons.language,
                      size: 80,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : AppTheme.etsLightRed,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 60),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppIntl.of(context).choose_language_title,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, top: 10, bottom: 30),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppIntl.of(context).choose_language_subtitle,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: languagesListView(model),
                    )
                  ],
                ),
              ),
            ));
  }
}
