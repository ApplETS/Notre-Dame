import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OutageTextSection extends StatelessWidget {
  final VoidCallback refreshOutageConfig;
  final double textPlacement;
  final double buttonPlacement;

  const OutageTextSection(
      {required this.textPlacement,
      required this.buttonPlacement,
      required this.refreshOutageConfig});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: textPlacement),
        Text(
          AppIntl.of(context)!.service_outage,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
        const SizedBox(height: 3),
        Text(
          AppIntl.of(context)!.service_outage_contact,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
        SizedBox(height: buttonPlacement),
        ElevatedButton(
          onPressed: () => refreshOutageConfig(),
          child: Text(
            AppIntl.of(context)!.service_outage_refresh,
            style: const TextStyle(fontSize: 17),
          ),
        ),
      ],
    );
  }
}
