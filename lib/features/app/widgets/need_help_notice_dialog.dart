// Flutter imports:
import 'package:flutter/material.dart';
import 'package:notredame/features/more/faq/faq_viewmodel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/utils/app_theme.dart';

class NeedHelpNoticeDialog extends AlertDialog {
  final FaqViewModel model;
  final double radius;
  final String link;

  const NeedHelpNoticeDialog({
    super.key,
    required this.model,
    required this.link,
    this.radius = 5.0,
  });

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(
          AppIntl.of(context)!.faq_questions_about_app_alert_title,
          style: const TextStyle(
              color: AppTheme.primary, fontWeight: FontWeight.bold),
        ),
        content: Text(
            AppIntl.of(context)!.faq_questions_about_app_alert_confirmation,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          getButtons(context),
        ],
      );

  Column getButtons(BuildContext context) {
    SizedBox helpPageButton = SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(AppTheme.primary),
                    foregroundColor: WidgetStateProperty.all<Color>(
                        AppTheme.lightThemeBackground),
                    textStyle: WidgetStateProperty.all<TextStyle>(
                        const TextStyle(fontWeight: FontWeight.bold)),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(radius)))),
                onPressed: () {
                  model.launchWebsite(
                      AppIntl.of(context)!.monets_connection_help_page);
                },
                icon: const Icon(Icons.help_center),
                label: Text(AppIntl.of(context)!
                    .faq_questions_about_app_alert_password_assistance),
              ),
            );
    
    SizedBox continueButton = SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(AppTheme.primary),
                    foregroundColor: WidgetStateProperty.all<Color>(
                        AppTheme.lightThemeBackground),
                    textStyle: WidgetStateProperty.all<TextStyle>(
                        const TextStyle(fontWeight: FontWeight.bold)),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(radius)))),
                onPressed: () => model.openMail(link, context),
                icon: const Icon(Icons.mail),
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
                              color: AppTheme.primary, width: 2.0),
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