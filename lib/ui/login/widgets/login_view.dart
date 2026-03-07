// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/login/view_model/login_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LoginViewModel>.reactive(
      viewModelBuilder: () => LoginViewModel(intl: AppIntl.of(context)!),
      builder: (context, model, child) => Scaffold(
        backgroundColor: context.theme.appColors.backgroundVibrant,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Hero(
                    tag: 'ets_logo',
                    child: SvgPicture.asset(
                      "assets/images/ets_white_logo.svg",
                      excludeFromSemantics: true,
                      width: 90,
                      height: 90,
                      colorFilter: ColorFilter.mode(context.theme.appColors.loginAccent, BlendMode.srcIn),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Text(
                    AppIntl.of(context)!.login_startup_title,
                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18, color: AppPalette.grey.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                          });
                          model.authenticate();
                        },
                        icon: const FaIcon(FontAwesomeIcons.lockOpen, color: Colors.white),
                        label: Text(
                          AppIntl.of(context)!.login_action_sign_in,
                          style: TextStyle(color: AppPalette.grey.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPalette.grey.darkGrey,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          minimumSize: const Size(300, 50),
                        ),
                      ),
                      if (_isLoading) ...[
                        CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppPalette.grey.white)),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      model.navigationService.pushNamed(RouterPaths.faq);
                    },
                    icon: const FaIcon(FontAwesomeIcons.question, color: Colors.white),
                    label: Text("FAQ"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.grey.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
}
