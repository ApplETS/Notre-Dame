// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/features/ets/quick-link/widgets/security-info/emergency_view.dart';
import 'package:notredame/features/ets/quick-link/widgets/security-info/security_viewmodel.dart';
import 'package:notredame/utils/app_theme.dart';

Widget securityEmergencyProcedures(
    BuildContext context, SecurityViewModel model) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          AppIntl.of(context)!.security_emergency_procedures,
          style: const TextStyle(color: AppTheme.etsLightRed, fontSize: 24),
        ),
      ),
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            model.emergencyProcedureList.length,
            (index) => Card(
              child: InkWell(
                splashColor: Colors.red.withAlpha(50),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EmergencyView(
                            model.emergencyProcedureList[index].title,
                            model.emergencyProcedureList[index].detail))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 16.0, bottom: 16.0, left: 16.0),
                      child: Text(
                        model.emergencyProcedureList[index].title,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
