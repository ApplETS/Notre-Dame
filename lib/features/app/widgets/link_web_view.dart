// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import 'package:notredame/features/app/widgets/base_scaffold.dart';
import 'package:notredame/features/ets/quick-link/models/quick_link.dart';

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
          WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..setNavigationDelegate(
                    NavigationDelegate(onPageFinished: (String url) {
                  setState(() {
                    isLoading = false;
                  });
                }))),
        ],
      ),
    );
  }
}
