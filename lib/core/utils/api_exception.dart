// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

/// Exception that can be thrown by the [SignetsApi]
class ApiException implements Exception {
  final String _message;
  final String _prefix;
  final String _errorCode;

  const ApiException(
      {@required String prefix, @required String message, String errorCode = ""})
      : _message = message,
        _prefix = prefix,
        _errorCode = errorCode;

  @override
  String toString() {
    return "$_prefix - Code: $_errorCode Message: $_message";
  }
}
