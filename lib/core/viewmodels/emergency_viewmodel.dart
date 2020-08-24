import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:notredame/core/viewmodels/security_viewmodel.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EmergencyViewModel extends SecurityViewModel {
  Future loadHtmlFromAssets(
      String filename, WebViewController controller) async {
    final String fileText = await rootBundle.loadString(filename);
    controller.loadUrl(Uri.dataFromString(fileText,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }
}
