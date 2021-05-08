// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

// MODELS
import 'package:notredame/core/models/quick_link.dart';
import 'package:notredame/ui/utils/loading.dart';

// OTHER
import 'package:webview_flutter/webview_flutter.dart';

class LinkWebView extends StatefulWidget {
  final QuickLink _links;

  const LinkWebView(this._links);

  @override
  _LinkWebViewState createState() => _LinkWebViewState();
}

class _LinkWebViewState extends State<LinkWebView> {
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._links.name),
      ),
      body: Stack(
        children: <Widget>[
          WebView(
            initialUrl: widget._links.link,
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (finish) {
              setState(() {
                isLoading = false;
              });
            },
          ),
          if (isLoading) buildLoading() else Stack(),
        ],
      ),
    );
  }
}