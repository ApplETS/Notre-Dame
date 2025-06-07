import 'package:flutter/cupertino.dart';
import 'package:notredame/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:stacked/stacked.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/themes/app_palette.dart';

class DaysLeftCard extends StatefulWidget {
  const DaysLeftCard({super.key});

  @override
  State<DaysLeftCard> createState() => _DaysLeftCardState();
}

class _DaysLeftCardState extends State<DaysLeftCard> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DashboardViewModel>.reactive(
        viewModelBuilder: () => DashboardViewModel(intl: AppIntl.of(context)!),
        builder: (context, model, child) {
          return Container(
            padding: const EdgeInsets.all(20),
            height: 145,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppPalette.grey.darkGrey,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              "Encore ${model.sessionDays[1] - model.sessionDays[0]} jours et c'est fini !",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: AppPalette.grey.white,
              ),
            ),
          );
        });
  }
}
