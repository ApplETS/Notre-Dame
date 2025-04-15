// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Project imports:
import 'package:notredame/ui/core/themes/app_theme.dart';

class LoginButton extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final bool canSubmit;
  final ValueGetter<Future<String>> authenticate;

  const LoginButton({super.key, required this.formKey, required this.canSubmit, required this.authenticate});

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
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
                      Fluttertoast.showToast(msg: error);
                    }
                    widget.formKey.currentState?.reset();
                  });
                },
          style: ButtonStyle(
            backgroundColor:
                WidgetStateProperty.all(widget.canSubmit ? context.theme.appColors.loginAccent : Colors.white38),
            padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
          ),
          child: Text(
            AppIntl.of(context)!.login_action_sign_in,
            style:
                TextStyle(color: widget.canSubmit ? context.theme.appColors.loginMain : Colors.white60, fontSize: 18),
          ),
        ),
      );
}
