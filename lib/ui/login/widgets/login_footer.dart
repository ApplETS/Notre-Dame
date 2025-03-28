// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';

class LoginFooter extends StatefulWidget {
  const LoginFooter({super.key});

  @override
  State<LoginFooter> createState() => _LoginFooterState();
}

class _LoginFooterState extends State<LoginFooter> {
  final NavigationService _navigationService = locator<NavigationService>();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 24),
          child: InkWell(
            child: Text(
              AppIntl.of(context)!.need_help,
              style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: AppPalette.grey.white),
            ),
            onTap: () async {
              _navigationService.pushNamed(RouterPaths.faq);
            },
          ),
        ),
      );
}
