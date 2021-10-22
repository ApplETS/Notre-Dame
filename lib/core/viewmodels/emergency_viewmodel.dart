// FLUTTER / DART / THIRD-PARTIES
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// VIEWMODEL
import 'package:notredame/core/viewmodels/security_viewmodel.dart';

class EmergencyViewModel extends SecurityViewModel {
  WebViewController webViewController;

  EmergencyViewModel({@required AppIntl intl}) : super(intl: intl);

  /// used to load the emergency procedures html files inside the webView
  Future loadHtmlFromAssets(String filename, Brightness brightness) async {
    final String fileText = await rootBundle.loadString(filename);

    final String data = Uri.dataFromString(darkMode(fileText, brightness),
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString();
    await webViewController.loadUrl(data);
  }

  /// used to add dark theme to emergency procedures html files
  String darkMode(String fileText, Brightness brightness) {
    String colorFileText = fileText;
    if (brightness == Brightness.dark) {
      colorFileText = colorFileText.replaceAll('<html>',
          "<html> <style> body { background-color: black; color: white;} </style>");
    }
    return colorFileText;
  }
}
