// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// VIEWMODELS
import 'package:notredame/core/viewmodels/not_found_viewmodel.dart';

// OTHER
import 'package:notredame/ui/utils/app_theme.dart';

class NotFoundView extends StatelessWidget {
  final String pageName;

  const NotFoundView({this.pageName});

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<NotFoundViewModel>.nonReactive(
          viewModelBuilder: () => NotFoundViewModel(pageName),
          builder: (context, model, child) => Scaffold(
                body: SafeArea(
                  minimum: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.only(
                            bottom: 40,
                          ),
                          child: Icon(
                            Icons.more_horiz,
                            color: AppTheme.primary,
                            size: 128.0,
                          ),
                        ),
                        Text(
                          AppIntl.of(context).not_found_title,
                          style: const TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 80,
                            bottom: 40,
                          ),
                          child: Text(
                            AppIntl.of(context)
                                .not_found_message(model.getNotFoundPageName()),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            primary: AppTheme.primary,
                          ),
                          onPressed: () {
                            model.navigateToDashboard();
                          },
                          child: Text(AppIntl.of(context).go_to_dashboard),
                        ),
                      ],
                    ),
                  ),
                ),
              ));
}
