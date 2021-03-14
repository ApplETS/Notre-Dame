// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// VIEWMODELS
import 'package:notredame/core/viewmodels/settings_viewmodel.dart';

// OTHERS
import 'package:notredame/ui/widgets/base_scaffold.dart';

class ChooseLanguageView extends StatefulWidget {
  @override
  _ChooseLanguageViewState createState() => _ChooseLanguageViewState();
}

class _ChooseLanguageViewState extends State<ChooseLanguageView> {
  Container languagesListView() {
    final List<String> languages = <String>[
      AppIntl.of(context).settings_english,
      AppIntl.of(context).settings_french
    ];

    return Container(
      height: 125.0,
      width: 200.0,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        itemCount: languages.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Container(
              height: 50,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(languages[index]),
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) =>
            Divider(color: Colors.grey[700]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SettingsViewModel>.reactive(
        viewModelBuilder: () => SettingsViewModel(intl: AppIntl.of(context)),
        builder: (context, model, child) {
          return BaseScaffold(
            body: SimpleDialog(
              insetPadding: const EdgeInsets.all(10),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.language,
                      size: 75,
                      color: AppTheme.etsLightRed,
                    ),
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
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: languagesListView(),
                ),
              ],
            ),
          );
        });
  }
}
