// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import 'package:notredame/core/utils/utils.dart';
import 'package:notredame/core/viewmodels/emergency_viewmodel.dart';
import 'package:notredame/ui/utils/app_theme.dart';

class EmergencyView extends StatefulWidget {
  final String title;
  final String description;

  const EmergencyView(this.title, this.description);

  @override
  _EmergencyViewState createState() => _EmergencyViewState();
}

class _EmergencyViewState extends State<EmergencyView> {
  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<EmergencyViewModel>.reactive(
        viewModelBuilder: () => EmergencyViewModel(intl: AppIntl.of(context)!),
        builder: (context, model, child) => Scaffold(
          appBar: AppBar(title: Text(widget.title)),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
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
            controller: WebViewController()
              ..loadFlutterAsset(widget.description)
          ),
        ),
      );
}
