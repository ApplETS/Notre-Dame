import 'package:flutter/material.dart';
import 'package:notredame/core/viewmodels/emergency_viewmodel.dart';
import 'package:notredame/generated/l10n.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:stacked/stacked.dart';
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
  Widget build(BuildContext context) =>
      ViewModelBuilder<EmergencyViewModel>.reactive(
        viewModelBuilder: () => EmergencyViewModel(),
        builder: (context, model, child) => Scaffold(
          appBar: AppBar(title: Text(widget.title)),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              model.makePhoneCall(
                  'tel:${AppIntl.of(context).security_emergency_number}');
            },
            label: Text(
              AppIntl.of(context).security_reach_security,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            icon: const Icon(Icons.phone, size: 30, color: Colors.white),
            backgroundColor: AppTheme.etsLightRed,
          ),
          body: WebView(
            initialUrl: '',
            onWebViewCreated: (WebViewController webViewController) async {
              _controller = webViewController;
              await model.loadHtmlFromAssets(widget.description, _controller);
            },
          ),
        ),
      );
}
