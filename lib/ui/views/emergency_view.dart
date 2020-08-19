import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notredame/core/viewmodels/quick_links_viewmodel.dart';
import 'package:notredame/generated/l10n.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EmergencyView extends StatefulWidget {
  final String title;
  final String description;
  const EmergencyView(this.title, this.description);

  @override
  _EmergencyViewState createState() => _EmergencyViewState();
}

class _EmergencyViewState extends State<EmergencyView> {
  WebViewController _controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          makePhoneCall('tel:${AppIntl.of(context).security_emergency_number}');
        },
        label: Text(
          AppIntl.of(context).security_reach_security,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        icon: const Icon(
          Icons.phone,
          size: 30,
          color: Colors.white,
        ),
        backgroundColor: AppTheme.etsLightRed,
      ),
      body: Column(children: [
        Expanded(
          child: WebView(
            initialUrl: '',
            onWebViewCreated: (WebViewController webViewController) async {
              _controller = webViewController;
              await loadHtmlFromAssets(widget.description, _controller);
            },
          ),
        ),
      ]),
    );
  }
}

Future<void> loadHtmlFromAssets(
    String filename, WebViewController controller) async {
  final String fileText = await rootBundle.loadString(filename);
  controller.loadUrl(Uri.dataFromString(fileText,
          mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
      .toString());
}
