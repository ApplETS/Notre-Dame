// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import 'package:notredame/features/app/presentation/webview_controller_extension.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/utils.dart';

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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Utils.launchURL(
                    'tel:${AppIntl.of(context)!.security_emergency_number}',
                    AppIntl.of(context)!)
                .catchError((error) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(error.toString())));
            });
          },
          label: Text(
            AppIntl.of(context)!.security_reach_security,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          icon: const Icon(Icons.phone, size: 30, color: Colors.white),
          backgroundColor: AppTheme.etsLightRed,
        ),
        body: WebViewWidget(
            controller: WebViewControllerExtension(WebViewController())
              ..loadHtmlFromAssets(
                  widget.description, Theme.of(context).brightness)),
      );
}
