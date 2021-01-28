// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

// VIEWMODEL
import 'package:notredame/core/viewmodels/setting_viewmodel.dart';

// WIDGETS
import 'package:notredame/ui/widgets/base_scaffold.dart';

// OTHERS
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/generated/l10n.dart';

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<SettingsViewModel>.reactive(
        viewModelBuilder: () => SettingsViewModel(),
        builder: (context, model, child) => BaseScaffold(
          appBar: AppBar(
            title: Text(AppIntl.of(context).settings_title),
          ),
          body: ListView(
            children: [
              ListTile(
                title: Text(
                  AppIntl.of(context).settings_display_pref_category,
                  style: const TextStyle(color: AppTheme.etsLightRed),
                ),
              ),
              PopupMenuButton(
                offset: Offset(MediaQuery.of(context).size.width, 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onSelected: (String value) {
                  setState(() {
                    model.selectedTheme = value;
                  });
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'light',
                    child: Text('Light'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'dark',
                    child: Text('Dark'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'system',
                    child: Text('System'),
                  ),
                ],
                child: ListTile(
                  leading: Icon(model.selectedTheme == 'light'
                      ? Icons.wb_sunny
                      : model.selectedTheme == 'dark'
                          ? Icons.nightlight_round
                          : Icons.brightness_auto),
                  title: Text(AppIntl.of(context).settings_dark_theme_pref),
                  subtitle: Text(model.selectedTheme),
                ),
              ),
              const Divider(
                thickness: 2,
                indent: 10,
                endIndent: 10,
              ),
              ListTile(
                title: Text(
                  AppIntl.of(context).settings_miscellaneous_category,
                  style: const TextStyle(color: AppTheme.etsLightRed),
                ),
              ),
              PopupMenuButton(
                offset: Offset(MediaQuery.of(context).size.width, 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onSelected: (String value) {
                  setState(() {
                    model.currentLocale = value;
                  });
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: AppIntl.of(context).settings_english,
                    child: Text(AppIntl.of(context).settings_english),
                  ),
                  PopupMenuItem<String>(
                    value: AppIntl.of(context).settings_french,
                    child: Text(AppIntl.of(context).settings_french),
                  ),
                ],
                child: ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(AppIntl.of(context).settings_language_pref),
                  subtitle: Text(model.currentLocale),
                ),
              ),
            ],
          ),
        ),
      );
}
