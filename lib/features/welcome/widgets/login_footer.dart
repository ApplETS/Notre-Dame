import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:notredame/utils/locator.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/theme/app_palette.dart';

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
              style: TextStyle(
                  decoration:
                  TextDecoration.underline,
                  color: AppPalette.grey.white),
            ),
            onTap: () async {
              _navigationService.pushNamed(RouterPaths.faq);
            },
          ),
        ),
      );
}
