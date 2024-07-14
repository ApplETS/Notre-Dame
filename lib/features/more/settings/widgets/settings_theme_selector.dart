import 'package:flutter/material.dart';
import 'package:notredame/features/more/settings/settings_viewmodel.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget settingsThemeSelector(BuildContext context, SettingsViewModel model,
    Function(ThemeMode) onSelected) {
  return Column(
    children: [
      ListTile(
        title: Text(
          AppIntl.of(context)!.settings_display_pref_category,
          style: const TextStyle(color: AppTheme.etsLightRed),
        ),
      ),
      PopupMenuButton(
        offset: Offset(MediaQuery.of(context).size.width, 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onSelected: onSelected,
        itemBuilder: (BuildContext context) => <PopupMenuEntry<ThemeMode>>[
          PopupMenuItem(
            value: ThemeMode.light,
            child: ListTile(
              title: Text(AppIntl.of(context)!.light_theme),
              leading: const Icon(Icons.wb_sunny),
            ),
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
          leading: Icon(model.selectedTheme == ThemeMode.light
              ? Icons.wb_sunny
              : model.selectedTheme == ThemeMode.dark
                  ? Icons.nightlight_round
                  : Icons.brightness_auto),
          title: Text(AppIntl.of(context)!.settings_dark_theme_pref),
          subtitle: Text(model.selectedTheme == ThemeMode.light
              ? AppIntl.of(context)!.light_theme
              : model.selectedTheme == ThemeMode.dark
                  ? AppIntl.of(context)!.dark_theme
                  : AppIntl.of(context)!.system_theme),
          trailing: const Icon(Icons.arrow_drop_down),
        ),
      ),
    ],
  );
}
