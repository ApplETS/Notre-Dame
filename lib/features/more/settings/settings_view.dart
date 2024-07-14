// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/features/more/settings/widgets/settings_language_selector.dart';
import 'package:notredame/features/more/settings/widgets/settings_theme_selector.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/app/widgets/base_scaffold.dart';
import 'package:notredame/features/more/settings/settings_viewmodel.dart';

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<SettingsViewModel>.reactive(
        viewModelBuilder: () => SettingsViewModel(intl: AppIntl.of(context)!),
        builder: (context, model, child) => BaseScaffold(
          appBar: AppBar(
            title: Text(AppIntl.of(context)!.settings_title),
          ),
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              settingsThemeSelector(context, model, (ThemeMode value) {
                setState(() {
                  model.selectedTheme = value;
                });
              }),
              const Divider(
                thickness: 2,
                indent: 10,
                endIndent: 10,
              ),
              settingsLanguageSelector(
                context,
                model,
                (String value) {
                  setState(() {
                    model.currentLocale = value;
                  });
                },
              )
            ],
          ),
        ),
      );
}
