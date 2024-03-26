// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import 'package:notredame/core/viewmodels/security_viewmodel.dart';

class EmergencyViewModel extends SecurityViewModel {
  EmergencyViewModel({required super.intl});

  /// used to load the emergency procedures html files inside the webView
  Future loadHtmlFromAssets(String filename, Brightness brightness,
      WebViewController webViewController) async {
    final String fileText = await rootBundle.loadString(filename);

    final String data = Uri.dataFromString(
            darkMode(scaleText(fileText), brightness),
            mimeType: 'text/html',
            encoding: Encoding.getByName('utf-8'))
        .toString();
    await webViewController.loadUrl(data);
  }

  /// used to add dark theme to emergency procedures html files
  String darkMode(String fileText, Brightness brightness) {
    String colorFileText = fileText;
    if (brightness == Brightness.dark) {
      colorFileText = colorFileText.replaceAll('<html>',
          "<html><style> body { background-color: black; color: white;} </style>");
    }

    return colorFileText;
  }

  String scaleText(String fileText) {
    return fileText.replaceAll(
        '<html>',
        // ignore: missing_whitespace_between_adjacent_strings
        "<html><meta name="
            "viewport"
            // ignore: missing_whitespace_between_adjacent_strings
            " content="
            // ignore: missing_whitespace_between_adjacent_strings
            'width=device-width, initial-scale=1.0'
            ">");
  }
}
