// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/features/ets/quick-link/widgets/security-info/widgets/security_emergency_procedures.dart';
import 'package:notredame/features/ets/quick-link/widgets/security-info/widgets/security_map.dart';
import 'package:notredame/features/ets/quick-link/widgets/security-info/widgets/security_phone_card.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/ets/quick-link/widgets/security-info/security_viewmodel.dart';

import 'package:notredame/features/app/widgets/base_scaffold.dart';

class SecurityView extends StatefulWidget {
  @override
  _SecurityViewState createState() => _SecurityViewState();
}

class _SecurityViewState extends State<SecurityView> {
  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<SecurityViewModel>.reactive(
        viewModelBuilder: () => SecurityViewModel(intl: AppIntl.of(context)!),
        builder: (context, model, child) => BaseScaffold(
          appBar: AppBar(
            title: Text(AppIntl.of(context)!.ets_security_title),
          ),
          showBottomBar: false,
          body: SafeArea(
            top: false,
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  securityMap(context, model),
                  securityPhoneCard(context),
                  securityEmergencyProcedures(context, model),
                ],
              ),
            ),
          ),
        ),
      );
}
