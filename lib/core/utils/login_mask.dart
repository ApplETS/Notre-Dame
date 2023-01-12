import 'package:flutter/services.dart';

class LoginMask extends TextInputFormatter {
  final numberOfLetters = 2;
  final maxCaracters = 8;

  ///Mask to match this regex "[A-Z]{2}[0-9]{5}"
  ///To use it add this mask to the inputFormatters in a TextField.
  LoginMask();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final int newTextLength = newValue.text.length;
    final StringBuffer newText = StringBuffer();

    if (newTextLength <= numberOfLetters &&
        RegExp("[a-zA-Z]").hasMatch(newValue.text)) {
      newText.write(newValue.text.toUpperCase());
    }

    if (newTextLength > numberOfLetters &&
        RegExp("^[0-9]*\$")
            .hasMatch(newValue.text.substring(2, newTextLength)) &&
        newTextLength < maxCaracters) {
      newText.write(newValue.text.toUpperCase());
    } else if (newTextLength > numberOfLetters &&
        newTextLength < maxCaracters) {
      newText.write(newValue.text.substring(0, newTextLength - 1));
    }

    if (newTextLength >= maxCaracters) {
      newText.write(newValue.text.substring(0, maxCaracters - 1));
    }

    return newValue.copyWith(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
