// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/choose_language/view_model/choose_language_viewmodel.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';

class ChooseLanguageView extends StatefulWidget {
  const ChooseLanguageView({super.key});

  @override
  State<ChooseLanguageView> createState() => _ChooseLanguageViewState();
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text(model.languages[index]),
                trailing: Icon(model.languageSelectedIndex == index ? Icons.check : null),
                onTap: () {
                  model.changeLanguage(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChooseLanguageViewModel>.reactive(
      viewModelBuilder: () => ChooseLanguageViewModel(intl: AppIntl.of(context)!),
      builder: (context, model, child) => Scaffold(
        backgroundColor: context.theme.appColors.backgroundVibrant,
        body: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Icon(Icons.language, size: 80, color: context.theme.appColors.loginAccent),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 60),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppIntl.of(context)!.choose_language_title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppPalette.grey.white),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 10, bottom: 30),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppIntl.of(context)!.choose_language_subtitle,
                    style: TextStyle(fontSize: 16, color: AppPalette.grey.white),
                  ),
                ),
              ),
              Padding(padding: const EdgeInsets.only(bottom: 80), child: languagesListView(model)),
            ],
          ),
        ),
      ),
    );
  }
}
