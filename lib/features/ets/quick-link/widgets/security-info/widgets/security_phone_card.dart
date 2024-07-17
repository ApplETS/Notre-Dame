// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/utils/utils.dart';

Widget securityPhoneCard(BuildContext context) {
  return Column(
    children: [
      Card(
        child: InkWell(
          splashColor: Colors.red.withAlpha(50),
          onTap: () => Utils.launchURL(
                  'tel:${AppIntl.of(context)!.security_emergency_number}',
                  AppIntl.of(context)!)
              .catchError((error) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(error.toString())));
          }),
          child: ListTile(
            leading: const Icon(Icons.phone, size: 30),
            title: Text(AppIntl.of(context)!.security_emergency_call),
            subtitle: Text(AppIntl.of(context)!.security_emergency_number),
          ),
        ),
      ),
      Card(
        elevation: 0,
        color: Colors.transparent,
        child: ListTile(
          leading: const Icon(Icons.phone, size: 30),
          title: Text(AppIntl.of(context)!.security_emergency_intern_call),
          subtitle: Text(AppIntl.of(context)!.security_emergency_intern_number),
        ),
      ),
    ],
  );
}
