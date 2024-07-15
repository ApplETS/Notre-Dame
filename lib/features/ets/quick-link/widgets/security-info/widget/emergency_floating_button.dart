// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/utils.dart';

class EmergencyFloatingButton extends StatelessWidget {
  const EmergencyFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Utils.launchURL('tel:${AppIntl.of(context)!.security_emergency_number}',
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
    );
  }
}
