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
            backgroundColor: AppTheme.etsLightRed,
            body: SafeArea(
              minimum: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/images/ets_white_logo.png',
                      excludeFromSemantics: true,
                      width: 216,
                      height: 216,
                    ),
                    const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                  ],
                ),
              ),
            ),
          ));
}
