// widgets/NeedHelpLink.dart

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/utils/utils.dart';
import 'package:notredame/utils/locator.dart';
import 'package:notredame/utils/app_theme.dart';

class NeedHelpLink extends StatelessWidget {
  final NavigationService _navigationService = locator<NavigationService>();

  NeedHelpLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: InkWell(
          child: Text(
            AppIntl.of(context)!.need_help,
            style: const TextStyle(
                decoration: TextDecoration.underline, color: Colors.white),
          ),
          onTap: () async {
            _navigationService.pushNamed(RouterPaths.faq,
                arguments: Utils.getColorByBrightness(
                    context, AppTheme.etsLightRed, AppTheme.primaryDark));
          },
        ),
      ),
    );
  }
}
