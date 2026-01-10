// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/ui/base_scaffold.dart';
import 'package:notredame/ui/more/settings/view_model/settings_viewmodel.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) => ViewModelBuilder<SettingsViewModel>.reactive(
    viewModelBuilder: () => SettingsViewModel(intl: AppIntl.of(context)!),
    builder: (context, model, child) => BaseScaffold(
      showBottomBar: false,
      appBar: AppBar(title: Text(AppIntl.of(context)!.settings_title)),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ListTile(
            title: Text(
              AppIntl.of(context)!.settings_display_pref_category,
              style: const TextStyle(color: AppPalette.etsLightRed),
            ),
          ),
          PopupMenuButton(
            offset: Offset(MediaQuery.of(context).size.width, 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onSelected: (ThemeMode value) {
              setState(() {
                model.selectedTheme = value;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<ThemeMode>>[
              PopupMenuItem(
                value: ThemeMode.light,
                child: ListTile(title: Text(AppIntl.of(context)!.light_theme), leading: const Icon(Icons.wb_sunny)),
              ),
              PopupMenuItem(
                value: ThemeMode.dark,
                child: ListTile(
                  title: Text(AppIntl.of(context)!.dark_theme),
                  leading: const Icon(Icons.nightlight_round),
                ),
              ),
              PopupMenuItem(
                value: ThemeMode.system,
                child: ListTile(
                  title: Text(AppIntl.of(context)!.system_theme),
                  leading: const Icon(Icons.brightness_auto),
                ),
              ),
            ],
            child: ListTile(
              leading: Icon(
                model.selectedTheme == ThemeMode.light
                    ? Icons.wb_sunny
                    : model.selectedTheme == ThemeMode.dark
                    ? Icons.nightlight_round
                    : Icons.brightness_auto,
              ),
              title: Text(AppIntl.of(context)!.settings_dark_theme_pref),
              subtitle: Text(
                model.selectedTheme == ThemeMode.light
                    ? AppIntl.of(context)!.light_theme
                    : model.selectedTheme == ThemeMode.dark
                    ? AppIntl.of(context)!.dark_theme
                    : AppIntl.of(context)!.system_theme,
              ),
              trailing: const Icon(Icons.arrow_drop_down),
            ),
          ),
          const Divider(thickness: 2, indent: 10, endIndent: 10),
          ListTile(
            title: Text(
              AppIntl.of(context)!.settings_miscellaneous_category,
              style: const TextStyle(color: AppPalette.etsLightRed),
            ),
          ),
          PopupMenuButton(
            offset: Offset(MediaQuery.of(context).size.width, 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onSelected: (String value) {
              setState(() {
                model.currentLocale = value;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: AppIntl.supportedLocales.first.languageCode,
                child: Text(AppIntl.of(context)!.settings_english),
              ),
              PopupMenuItem<String>(
                value: AppIntl.supportedLocales.last.languageCode,
                child: Text(AppIntl.of(context)!.settings_french),
              ),
            ],
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text(AppIntl.of(context)!.settings_language_pref),
              subtitle: Text(model.currentLocale),
              trailing: const Icon(Icons.arrow_drop_down),
            ),
          ),
        ],
      ),
    ),
  );
}
