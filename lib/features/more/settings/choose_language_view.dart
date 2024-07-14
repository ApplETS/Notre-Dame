import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/features/more/settings/widget/language_list_widget.dart';
import 'package:stacked/stacked.dart';
import 'package:notredame/utils/utils.dart';
import 'package:notredame/features/more/settings/choose_language_viewmodel.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/utils.dart';

class ChooseLanguageView extends StatefulWidget {
  @override
  _ChooseLanguageViewState createState() => _ChooseLanguageViewState();
}

class _ChooseLanguageViewState extends State<ChooseLanguageView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChooseLanguageViewModel>.reactive(
      viewModelBuilder: () =>
          ChooseLanguageViewModel(intl: AppIntl.of(context)!),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Utils.getColorByBrightness(
            context, AppTheme.etsLightRed, AppTheme.primaryDark),
        body: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Icon(
                Icons.language,
                size: 80,
                color: Utils.getColorByBrightness(
                    context, Colors.white, AppTheme.etsLightRed),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 60),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppIntl.of(context)!.choose_language_title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 10, bottom: 30),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppIntl.of(context)!.choose_language_subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: LanguageListViewWidget(model: model),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
