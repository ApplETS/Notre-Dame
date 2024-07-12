// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/app/startup/startup_viewmodel.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/utils.dart';

class StartUpView extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<StartUpViewModel>.nonReactive(
          viewModelBuilder: () => StartUpViewModel(),
          onViewModelReady: (StartUpViewModel model) {
            model.handleStartUp();
          },
          builder: (context, model, child) => Scaffold(
                backgroundColor: Utils.getColorByBrightness(
                    context, AppTheme.etsLightRed, AppTheme.primaryDark),
                body: SafeArea(
                  minimum: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Hero(
                            tag: 'ets_logo',
                            child: SvgPicture.asset(
                              "assets/images/ets_white_logo.svg",
                              excludeFromSemantics: true,
                              width: 90,
                              height: 90,
                              colorFilter: ColorFilter.mode(
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : AppTheme.etsLightRed,
                                  BlendMode.srcIn),
                            )),
                        const SizedBox(
                          height: 15,
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
