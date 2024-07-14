import 'package:flutter/material.dart';
import 'package:notredame/features/student/profile/profile_viewmodel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Card getMyBalanceCard(ProfileViewModel model, BuildContext context) {
  final stringBalance = model.profileStudent.balance;
  var balance = 0.0;

  if (stringBalance.isNotEmpty) {
    balance = double.parse(stringBalance
        .substring(0, stringBalance.length - 1)
        .replaceAll(",", "."));
  }

  return Card(
    color: balance > 0 ? Colors.red : Colors.green,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16.0, bottom: 3.0),
          child: Text(
            AppIntl.of(context)!.profile_balance,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Center(
            child: Text(
              stringBalance,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    ),
  );
}
