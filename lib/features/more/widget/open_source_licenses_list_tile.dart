// widgets/open_source_licenses_tile.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:notredame/utils/utils.dart';
import 'package:stacked/stacked.dart';
import 'package:notredame/features/more/more_viewmodel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OpenSourceLicensesTile extends ViewModelWidget<MoreViewModel> {
  const OpenSourceLicensesTile({super.key});

  @override
  Widget build(BuildContext context, MoreViewModel model) {
    return ListTile(
      title: Text(AppIntl.of(context)!.more_open_source_licenses),
      leading: const Icon(Icons.code),
      onTap: () {
        model.analyticsService.logEvent("MoreView", "Rate us clicked");
        Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (context, _, __) => AboutDialog(
            applicationIcon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                  width: 75,
                  child: Image.asset('assets/images/favicon_applets.png')),
            ),
            applicationName: AppIntl.of(context)!.more_open_source_licenses,
            applicationVersion: model.appVersion,
            applicationLegalese: '\u{a9} ${DateTime.now().year} App|ETS',
            children: aboutBoxChildren(context, model),
          ),
          opaque: false,
        ));
      },
    );
  }

  List<Widget> aboutBoxChildren(BuildContext context, MoreViewModel model) {
    final textStyle = Theme.of(context).textTheme.bodyMedium!;
    return <Widget>[
      const SizedBox(height: 24),
      RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
                style: textStyle, text: AppIntl.of(context)!.flutter_license),
            TextSpan(
                style: textStyle.copyWith(color: Colors.blue),
                text: AppIntl.of(context)!.flutter_website,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Utils.launchURL(
                      AppIntl.of(context)!.flutter_website,
                      AppIntl.of(context)!)),
            TextSpan(style: textStyle, text: '.'),
          ],
        ),
      ),
    ];
  }
}
