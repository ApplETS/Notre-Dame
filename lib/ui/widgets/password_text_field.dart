// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PasswordFormField extends StatefulWidget {
  final FormFieldValidator<String> validator;
  final VoidCallback onEditionComplete;

  const PasswordFormField(
      {super.key, required this.validator, required this.onEditionComplete});

  @override
  _PasswordFormFieldState createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  /// Define if the password is visible or not
  bool _obscureText = true;

  final double borderRadiusOnFocus = 2.0;

  @override
  Widget build(BuildContext context) => TextFormField(
        autofillHints: const [AutofillHints.password],
        cursorColor: Colors.white,
        obscureText: _obscureText,
        decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white70)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.white, width: borderRadiusOnFocus)),
            focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: errorTextColor, width: borderRadiusOnFocus)),
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: errorTextColor, width: borderRadiusOnFocus)),
            labelText: AppIntl.of(context)!.login_prompt_password,
            labelStyle: const TextStyle(color: Colors.white54),
            errorStyle: TextStyle(color: errorTextColor),
            suffixIcon: IconButton(
                icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white),
                onPressed: _toggle)),
        style: const TextStyle(color: Colors.white),
        validator: widget.validator,
        onEditingComplete: widget.onEditionComplete,
      );

  /// Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Color get errorTextColor => Theme.of(context).brightness == Brightness.light
      ? Colors.amberAccent
      : Colors.redAccent;
}
