// Flutter imports:
import 'package:flutter/material.dart';
import 'package:notredame/ui/core/ui/titled_card.dart';

// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';
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
    viewModelBuilder: () => SettingsViewModel(),
    builder: (context, model, child) => BaseScaffold(
      appBar: AppBar(title: Text(AppIntl.of(context)!.settings_title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child:
            Column(
              spacing: 12.0,
              children: [
                TitledCard(
                  title: AppIntl.of(context)!.settings_display_pref_category,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        SegmentedButton<ThemeMode>(
                          segments: <ButtonSegment<ThemeMode>>[
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.light,
                              label: Text(AppIntl.of(context)!.light_theme),
                              icon: Icon(Icons.wb_sunny),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.dark,
                              label: Text(AppIntl.of(context)!.dark_theme),
                              icon: Icon(Icons.nightlight_round),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.system,
                              label: Text(AppIntl.of(context)!.system_theme),
                              icon: Icon(Icons.brightness_auto),
                            ),
                          ],
                          showSelectedIcon: false,
                          emptySelectionAllowed: true,
                          selected: model.theme != null ? <ThemeMode>{model.theme!} : {},
                          onSelectionChanged: (Set<ThemeMode> value) {
                            if (value.isNotEmpty) {
                              model.theme = value.first;
                            }
                          },
                        ),
                        SizedBox(height: 16.0),
                        Text("Format du calendrier sur le dashboard :"),
                        SegmentedButton<bool>(
                          segments: <ButtonSegment<bool>>[
                            ButtonSegment<bool>(value: true, label: Text("Liste"), icon: Icon(Icons.list)),
                            ButtonSegment<bool>(value: false, label: Text("Calendrier"), icon: Icon(Icons.calendar_month)),
                          ],
                          selected: <bool>{model.dashboardScheduleList},
                          showSelectedIcon: false,
                          emptySelectionAllowed: true,
                          onSelectionChanged: (Set<bool> value) {
                            if (value.isNotEmpty) {
                              model.dashboardScheduleList = value.first;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                TitledCard(
                  title: AppIntl.of(context)!.settings_language_pref,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        SegmentedButton<Locale>(
                          segments: <ButtonSegment<Locale>>[
                            ButtonSegment<Locale>(
                              value: AppIntl.supportedLocales.first,
                              label: Text(AppIntl.of(context)!.settings_english),
                            ),
                            ButtonSegment<Locale>(
                              value: AppIntl.supportedLocales.last,
                              label: Text(AppIntl.of(context)!.settings_french),
                            ),
                          ],
                          emptySelectionAllowed: true,
                          selected: <Locale>{model.locale},
                          onSelectionChanged: (Set<Locale> value) {
                            if (value.isNotEmpty) {
                              model.locale = value.first;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ),
      ),
    ),
  );
}
