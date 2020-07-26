// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

// OTHER
import 'package:notredame/generated/l10n.dart';

class PasswordFormField extends StatefulWidget {
  final FormFieldValidator<String> validator;

  const PasswordFormField({Key key, this.validator}) : super(key: key);

  @override
  _PasswordFormFieldState createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  /// Define if the password is visible or not
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) => TextFormField(
        cursorColor: Colors.white,
        obscureText: _obscureText,
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white70)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2.0)),
            labelText: AppIntl.of(context).login_prompt_password,
            labelStyle: TextStyle(color: Colors.white54),
            suffixIcon: IconButton(
                icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white),
                onPressed: _toggle)),
        style: TextStyle(color: Colors.white),
        validator: widget.validator,
      );

  /// Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}
