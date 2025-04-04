// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// Project imports:
import 'package:notredame/data/services/launch_url_service.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/ui/base_scaffold.dart';

class EmergencyView extends StatefulWidget {
  final String title;
  final String description;

  const EmergencyView(this.title, this.description, {super.key});

  @override
  State<EmergencyView> createState() => _EmergencyViewState();
}

class _EmergencyViewState extends State<EmergencyView> {
  final LaunchUrlService _launchUrlService = locator<LaunchUrlService>();

  @override
  Widget build(BuildContext context) => BaseScaffold(
      appBar: AppBar(title: Text(widget.title)),
      showBottomBar: false,
      safeArea: false,
      fabPosition: FloatingActionButtonLocation.centerFloat,
      fab: FloatingActionButton.extended(
        onPressed: () {
          try {
            _launchUrlService
                .call(AppIntl.of(context)!.security_emergency_number);
          } catch (e) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(e.toString())));
          }
        },
        label: Text(
          AppIntl.of(context)!.security_reach_security,
          style: TextStyle(color: AppPalette.grey.white, fontSize: 20),
        ),
        icon: Icon(Icons.phone, size: 30, color: AppPalette.grey.white),
        backgroundColor: AppPalette.etsLightRed,
      ),
      body: FutureBuilder<String>(
          future: rootBundle.loadString(widget.description),
          builder: (context, AsyncSnapshot<String> fileContent) {
            if (fileContent.hasData) {
              return SafeArea(
                  top: false,
                  bottom: false,
                  child: Scrollbar(
                    child: Markdown(
                        padding: const EdgeInsets.only(
                            bottom: 120, top: 12, left: 12, right: 12),
                        data: fileContent.data!),
                  ));
            }
            // Loading a file is so fast showing a spinner would make the user experience worse
            return const SizedBox.shrink();
          }));
}
