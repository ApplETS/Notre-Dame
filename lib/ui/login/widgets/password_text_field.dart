// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';

class PasswordFormField extends StatefulWidget {
  final FormFieldValidator<String> validator;
  final VoidCallback onEditionComplete;

  const PasswordFormField(
      {super.key, required this.validator, required this.onEditionComplete});

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  /// Define if the password is visible or not
  bool _obscureText = true;

  final double borderRadiusOnFocus = 2.0;

  @override
  Widget build(BuildContext context) => TextFormField(
        autofillHints: const [AutofillHints.password],
        cursorColor: AppPalette.grey.white,
        obscureText: _obscureText,
        decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white70)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: AppPalette.grey.white, width: borderRadiusOnFocus)),
            focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: context.theme.appColors.inputError,
                    width: borderRadiusOnFocus)),
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: context.theme.appColors.inputError,
                    width: borderRadiusOnFocus)),
            labelText: AppIntl.of(context)!.login_prompt_password,
            labelStyle: const TextStyle(color: Colors.white54),
            errorStyle: TextStyle(color: context.theme.appColors.inputError),
            suffixIcon: IconButton(
                icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: AppPalette.grey.white),
                onPressed: _toggle)),
        style: TextStyle(color: AppPalette.grey.white),
        validator: widget.validator,
        onEditingComplete: widget.onEditionComplete,
      );

  /// Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}
