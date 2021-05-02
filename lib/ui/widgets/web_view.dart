// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:notredame/core/models/quick_link.dart';

// OTHER
import 'package:webview_flutter/webview_flutter.dart';

class WebViewCard extends StatelessWidget {
  final QuickLink _links;

  const WebViewCard(this._links);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_links.name),
      ),
      body: WebView(
        initialUrl: _links.link,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}