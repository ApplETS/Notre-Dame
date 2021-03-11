// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:stacked/stacked.dart';

// VIEW MODEL
import 'package:notredame/core/viewmodels/startup_viewmodel.dart';

class StartUpView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ViewModelBuilder.nonReactive(
      viewModelBuilder: () => StartUpViewModel(),
      onModelReady: (StartUpViewModel model) => model.handleStartUp(),
      builder: (context, model, child) => Scaffold(
            backgroundColor: model.getAppTheme() == ThemeMode.light.toString()
                ? AppTheme.etsLightRed
                : model.getAppTheme() == ThemeMode.dark.toString()
                    ? AppTheme.primaryDark
                    : Theme.of(context).brightness == Brightness.light
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
                        model.getAppTheme() == ThemeMode.light.toString()
                            ? "assets/images/ets_white_logo.png"
                            : model.getAppTheme() == ThemeMode.dark.toString()
                                ? "assets/images/ets_red_logo.png"
                                : Theme.of(context).brightness ==
                                        Brightness.light
                                    ? "assets/images/ets_white_logo.png"
                                    : "assets/images/ets_red_logo.png",
                        excludeFromSemantics: true,
                        width: 216,
                        height: 216,
                      ),
                    ),
                    const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                  ],
                ),
              ),
            ),
          ));
}
