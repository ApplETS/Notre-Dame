// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

// OTHER
import 'package:notredame/generated/l10n.dart';

class PasswordFormField extends StatefulWidget {
  final FormFieldValidator<String> validator;
  final VoidCallback onEditionComplete;

  const PasswordFormField({Key key, this.validator, this.onEditionComplete})
      : super(key: key);

  @override
  _PasswordFormFieldState createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  /// Define if the password is visible or not
  bool _obscureText = true;

  final double borderRadiusOnFocus = 2.0;

  @override
  Widget build(BuildContext context) => TextFormField(
        autofillHints: [AutofillHints.password],
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
                    color: Colors.amberAccent, width: borderRadiusOnFocus)),
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.amberAccent, width: borderRadiusOnFocus)),
            labelText: AppIntl.of(context).login_prompt_password,
            labelStyle: const TextStyle(color: Colors.white54),
            errorStyle: const TextStyle(color: Colors.amberAccent),
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
}
