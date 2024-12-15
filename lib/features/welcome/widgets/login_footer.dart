import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/utils/utils.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/domain/constants/router_paths.dart';

class LoginFooter extends StatefulWidget{

  const LoginFooter(
      {super.key});

  @override
  State<LoginFooter> createState() => _LoginFooterState();
}

class _LoginFooterState extends State<LoginFooter>{
  final NavigationService _navigationService = locator<NavigationService>();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 24),
          child: InkWell(
            child: Text(
              AppIntl.of(context)!.need_help,
              style: const TextStyle(
                  decoration:
                  TextDecoration.underline,
                  color: Colors.white),
            ),
            onTap: () async {
              _navigationService.pushNamed(
                  RouterPaths.faq,
                  arguments:
                  Utils.getColorByBrightness(
                      context,
                      AppTheme.etsLightRed,
                      AppTheme.primaryDark));
            },
          ),
        ),
      );
}
