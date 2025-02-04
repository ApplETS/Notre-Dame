// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:notredame/theme/app_theme.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/ui/startup/view_model/startup_viewmodel.dart';
import 'package:notredame/theme/app_palette.dart';

class StartUpView extends StatelessWidget {
  const StartUpView({super.key});

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<StartUpViewModel>.nonReactive(
          viewModelBuilder: () => StartUpViewModel(),
          onViewModelReady: (StartUpViewModel model) {
            model.handleStartUp();
          },
          builder: (context, model, child) => Scaffold(
                backgroundColor: context.theme.appColors.backgroundVibrant,
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
                                  context.theme.appColors.loginAccent,
                                  BlendMode.srcIn),
                            )),
                        const SizedBox(
                          height: 15,
                        ),
                        CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppPalette.grey.white))
                      ],
                    ),
                  ),
                ),
              ));
}
