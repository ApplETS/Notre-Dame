// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// Project imports:
import 'package:notredame/features/app/widgets/base_scaffold.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/data/services/launch_url_service.dart';

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
            _launchUrlService.call(AppIntl.of(context)!.security_emergency_number);
          } catch (e) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(e.toString())));
          }
        },
        label: Text(
          AppIntl.of(context)!.security_reach_security,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        icon: const Icon(Icons.phone, size: 30, color: Colors.white),
        backgroundColor: AppTheme.etsLightRed,
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
