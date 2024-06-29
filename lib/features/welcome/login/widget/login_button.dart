// widgets/LoginButton.dart

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notredame/features/welcome/login/login_viewmodel.dart';
import 'package:notredame/utils/utils.dart';
import 'package:notredame/utils/app_theme.dart';

class LoginButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final LoginViewModel model;

  const LoginButton({super.key, required this.formKey, required this.model});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: !model.canSubmit
            ? null
            : () async {
                final String error = await model.authenticate();

                if (error.isNotEmpty) {
                  Fluttertoast.showToast(msg: error);
                }
                formKey.currentState?.reset();
              },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
              model.canSubmit ? colorButton(context) : Colors.white38),
          padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(vertical: 16)),
        ),
        child: Text(
          AppIntl.of(context)!.login_action_sign_in,
          style: TextStyle(
              color:
                  model.canSubmit ? submitTextColor(context) : Colors.white60,
              fontSize: 18),
        ),
      ),
    );
  }

  Color colorButton(BuildContext context) =>
      Utils.getColorByBrightness(context, Colors.white, AppTheme.etsLightRed);

  Color submitTextColor(BuildContext context) =>
      Utils.getColorByBrightness(context, AppTheme.etsLightRed, Colors.white);
}
