import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notredame/core/viewmodels/quick_links_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class QuickLinksWidget extends StatelessWidget {
  final QuickLinks _links;
  const QuickLinksWidget(this._links);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 125,
      height: 125,
      child: Card(
        elevation: 4.0,
        color: Colors.white,
        child: InkWell(
          splashColor: Colors.red.withAlpha(50),
          onTap: onLinkClicked,
          child: Column(
            children: [
              Expanded(
                flex: 40,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Image.asset(_links.image),
                ),
              ),
              Text(
                _links.name,
                style: const TextStyle(color: Colors.red, fontSize: 20.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onLinkClicked() {
    if (_links.link != null) _launchInBrowser(_links.link);
  }
}

Future<void> _launchInBrowser(String url) async {
  if (await canLaunch(url)) {
    await launch(
      url,
      forceSafariVC: true,
      forceWebView: true,
      enableJavaScript: true,
    );
  } else {
    throw 'Could not launch $url';
  }
}
