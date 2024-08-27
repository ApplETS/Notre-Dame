import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/features/app/error/outage/outage_viewmodel.dart';

class OutageTextSection extends StatefulWidget {
  final OutageViewModel viewModel;

  const OutageTextSection(this.viewModel);

  @override
  State<StatefulWidget> createState() => _OutageTextSectionState();
}

class _OutageTextSectionState extends State<OutageTextSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        SizedBox(height: widget.viewModel.getButtonPlacement()),
        ElevatedButton(
          onPressed: () {
            widget.viewModel.refreshOutageConfig();
          },
          child: Text(
            AppIntl.of(context)!.service_outage_refresh,
            style: const TextStyle(fontSize: 17),
          ),
        ),
      ],
    );
  }
}
