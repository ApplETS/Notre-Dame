import 'package:flutter/material.dart';
import 'package:notredame/features/ets/quick-link/widgets/security-info/widget/emergency_floating_button.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:notredame/features/app/presentation/webview_controller_extension.dart';

class EmergencyView extends StatefulWidget {
  final String title;
  final String description;

  const EmergencyView(this.title, this.description);

  @override
  _EmergencyViewState createState() => _EmergencyViewState();
}

class _EmergencyViewState extends State<EmergencyView> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: const EmergencyFloatingButton(),
        body: WebViewWidget(
          controller: WebViewControllerExtension(WebViewController())
            ..loadHtmlFromAssets(
                widget.description, Theme.of(context).brightness),
        ),
      );
}
