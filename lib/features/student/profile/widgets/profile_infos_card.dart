import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/features/student/profile/profile_viewmodel.dart';

Card getMyInfosCard(ProfileViewModel model, BuildContext context) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Clipboard.setData(
                  ClipboardData(text: model.profileStudent.permanentCode));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(AppIntl.of(context)!
                    .profile_permanent_code_copied_to_clipboard),
              ));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 3.0),
                  child: Text(
                    AppIntl.of(context)!.profile_permanent_code,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    model.profileStudent.permanentCode,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: model.universalAccessCode));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(AppIntl.of(context)!
                    .profile_universal_code_copied_to_clipboard),
              ));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 3.0),
                  child: Text(
                    AppIntl.of(context)!.login_prompt_universal_code,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Center(
                  child: Text(
                    model.universalAccessCode,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
