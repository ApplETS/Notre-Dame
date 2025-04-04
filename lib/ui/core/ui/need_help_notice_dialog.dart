// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/ui/core/themes/app_palette.dart';

class NeedHelpNoticeDialog extends AlertDialog {
  final VoidCallback openMail;
  final VoidCallback launchWebsite;
  final double radius;

  const NeedHelpNoticeDialog({
    super.key,
    required this.openMail,
    required this.launchWebsite,
    this.radius = 8.0,
  });

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(
          AppIntl.of(context)!.faq_questions_app_alert_title,
          style: const TextStyle(
              color: AppPalette.etsLightRed, fontWeight: FontWeight.bold),
        ),
        content: Text(AppIntl.of(context)!.faq_questions_app_alert_confirmation,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          getButtons(context),
        ],
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      );

  Column getButtons(BuildContext context) {
    SizedBox helpPageButton = SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        style: ButtonStyle(
            backgroundColor:
                WidgetStateProperty.all<Color>(AppPalette.etsLightRed),
            foregroundColor:
                WidgetStateProperty.all<Color?>(AppPalette.grey.white),
            textStyle: WidgetStateProperty.all<TextStyle>(
                const TextStyle(fontWeight: FontWeight.bold)),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radius)))),
        onPressed: () {
          launchWebsite();
        },
        icon: Icon(Icons.help, color: AppPalette.grey.white),
        label: Text(
            AppIntl.of(context)!.faq_questions_app_alert_password_assistance),
      ),
    );

    SizedBox continueButton = SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        style: ButtonStyle(
            backgroundColor:
                WidgetStateProperty.all<Color>(AppPalette.etsLightRed),
            foregroundColor:
                WidgetStateProperty.all<Color>(AppPalette.grey.white),
            textStyle: WidgetStateProperty.all<TextStyle>(
                const TextStyle(fontWeight: FontWeight.bold)),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radius)))),
        onPressed: openMail,
        icon: Icon(Icons.mail, color: AppPalette.grey.white),
        label: Text(AppIntl.of(context)!.continue_to_mail_app),
      ),
    );

    SizedBox cancelButton = SizedBox(
      width: double.infinity,
      child: TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          style: ButtonStyle(
              textStyle: WidgetStateProperty.all<TextStyle>(
                  const TextStyle(fontWeight: FontWeight.bold)),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                  side: const BorderSide(
                      color: AppPalette.etsLightRed, width: 2.0),
                  borderRadius: BorderRadius.circular(radius)))),
          icon: const Icon(Icons.cancel),
          label: Text(AppIntl.of(context)!.cancel_button_text)),
    );

    return Column(
      children: [
        helpPageButton,
        continueButton,
        cancelButton,
      ],
    );
  }
}
