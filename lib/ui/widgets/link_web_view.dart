// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// MODELS
import 'package:notredame/core/models/quick_link.dart';

// WIDGETS
import 'package:notredame/ui/widgets/base_scaffold.dart';

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
    return BaseScaffold(
      isLoading: isLoading,
      showBottomBar: false,
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
        ],
      ),
    );
  }
}