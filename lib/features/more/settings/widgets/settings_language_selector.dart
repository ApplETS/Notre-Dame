import 'package:flutter/material.dart';
import 'package:notredame/features/more/settings/settings_viewmodel.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget settingsLanguageSelector(BuildContext context, SettingsViewModel model,
        Function(String)? onSelected) =>
    Column(children: <Widget>[
      ListTile(
        title: Text(
          AppIntl.of(context)!.settings_miscellaneous_category,
          style: const TextStyle(color: AppTheme.etsLightRed),
        ),
      ),
      PopupMenuButton(
        offset: Offset(MediaQuery.of(context).size.width, 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onSelected: onSelected,
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
    ]);
