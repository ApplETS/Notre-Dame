// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/core/viewmodels/not_found_viewmodel.dart';

import 'package:stacked/stacked.dart';
import 'package:notredame/generated/l10n.dart';

class NotFoundView extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<NotFoundViewModel>.nonReactive(
          viewModelBuilder: () => NotFoundViewModel(),
          builder: (context, model, child) => Scaffold(
                backgroundColor: AppTheme.lightTheme.canvasColor,
                body: SafeArea(
                  minimum: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          AppIntl.of(context).not_found_title,
                          style: const TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 40,
                            bottom: 80,
                          ),
                          child: Text(
                            AppIntl.of(context).not_found_message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                        FlatButton(
                          color: AppTheme.primary,
                          onPressed: () {
                            model.navigateToDashboard();
                          },
                          child: Text(
                            AppIntl.of(context).title_dashboard,
                            style: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ));
}
