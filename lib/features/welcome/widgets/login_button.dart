import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/utils/utils.dart';
import 'package:notredame/theme/app_palette.dart';

class LoginButton extends StatefulWidget{
  final GlobalKey<FormState> formKey;
  final bool canSubmit;
  final ValueGetter<Future<String>> authenticate;

  const LoginButton({
    super.key,
    required this.formKey,
    required this.canSubmit,
    required this.authenticate});

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton>{

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: !widget.canSubmit
              ? null
              : () async {
            final String error = await widget.authenticate();

            setState(() {
              if (error.isNotEmpty) {
                Fluttertoast.showToast(
                    msg: error);
              }
              widget.formKey.currentState?.reset();
            });
          },
          style: ButtonStyle(
            backgroundColor:
            WidgetStateProperty.all(
                widget.canSubmit
                    ? colorButton
                    : Colors.white38),
            padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(
                    vertical: 16)),
          ),
          child: Text(
            AppIntl.of(context)!
                .login_action_sign_in,
            style: TextStyle(
                color: widget.canSubmit
                    ? submitTextColor
                    : Colors.white60,
                fontSize: 18),
          ),
        ),
      );

  Color get colorButton =>
      Utils.getColorByBrightness(context, AppPalette.grey.white, AppPalette.etsLightRed);

  Color get submitTextColor =>
      Utils.getColorByBrightness(context, AppPalette.etsLightRed, AppPalette.grey.white);

}
