// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

// VIEW MODEL
import 'package:notredame/core/viewmodels/startup_viewmodel.dart';

// OTHER
import 'package:notredame/ui/utils/app_theme.dart';

class StartUpView extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<StartUpViewModel>.nonReactive(
          viewModelBuilder: () => StartUpViewModel(),
          onModelReady: (StartUpViewModel model) => model.handleStartUp(),
          builder: (context, model, child) => Scaffold(
                backgroundColor:
                    Theme.of(context).brightness == Brightness.light
                        ? AppTheme.etsLightRed
                        : AppTheme.primaryDark,
                body: SafeArea(
                  minimum: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Hero(
                          tag: 'ets_logo',
                          child: Image.asset(
                            "assets/images/ets_red_logo.png",
                            excludeFromSemantics: true,
                            width: 216,
                            height: 216,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? AppTheme.etsLightRed
                                    : Colors.white,
                          ),
                        ),
                        const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white))
                      ],
                    ),
                  ),
                ),
              ));
}
