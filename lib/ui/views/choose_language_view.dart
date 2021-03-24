// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// VIEWMODELS
import 'package:notredame/core/viewmodels/choose_language_viewmodel.dart';

// OTHER
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';

class ChooseLanguageView extends StatefulWidget {
  @override
  _ChooseLanguageViewState createState() => _ChooseLanguageViewState();
}

class _ChooseLanguageViewState extends State<ChooseLanguageView> {
  SizedBox languagesListView(ChooseLanguageViewModel model) {
    return SizedBox(
      height: 125.0,
      width: 200.0,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        itemCount: model.languages.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            trailing:
                Icon(model.languageSelectedIndex == index ? Icons.check : null),
            title: Text(model.languages[index]),
            onTap: () {
              model.changeLanguage(index);
            },
          );
        },
        separatorBuilder: (BuildContext context, int index) =>
            Divider(color: Colors.grey[700]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChooseLanguageViewModel>.reactive(
        viewModelBuilder: () => ChooseLanguageViewModel(intl: AppIntl.of(context)),
        builder: (context, model, child) => Scaffold(
            backgroundColor: Theme.of(context).brightness == Brightness.light
              ? AppTheme.etsLightRed
              : AppTheme.primaryDark,
            body: Center(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Center(
                    child: Icon(
                      Icons.language,
                      size: 75,
                      color: Theme.of(context).brightness == Brightness.light
                        ?  Colors.black
                        : AppTheme.etsLightRed,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppIntl.of(context).choose_language_title,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppIntl.of(context).choose_language_subtitle,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  languagesListView(model)
                ],
              ),
            ),
          )
        );
  }
}
