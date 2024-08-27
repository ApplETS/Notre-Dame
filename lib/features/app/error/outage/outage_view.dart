// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/features/app/error/outage/widgets/outage_image_section.dart';
import 'package:notredame/features/app/error/outage/widgets/outage_social_section.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/utils/utils.dart';
import 'package:notredame/features/app/error/outage/outage_viewmodel.dart';
import 'package:notredame/utils/app_theme.dart';

class OutageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<OutageViewModel>.nonReactive(
          viewModelBuilder: () => OutageViewModel(context),
          builder: (context, model, child) => Scaffold(
                backgroundColor: Utils.getColorByBrightness(
                    context, AppTheme.etsLightRed, AppTheme.primaryDark),
                body: Stack(
                  children: [
                    SafeArea(
                      minimum: const EdgeInsets.all(20),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: model.getImagePlacement(),
                          ),
                          OutageImageSection(),
                          SizedBox(height: model.getTextPlacement()),
                          Text(
                            AppIntl.of(context)!.service_outage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            AppIntl.of(context)!.service_outage_contact,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: model.getButtonPlacement()),
                          ElevatedButton(
                            onPressed: () {
                              model.refreshOutageConfig();
                            },
                            child: Text(
                              AppIntl.of(context)!.service_outage_refresh,
                              style: const TextStyle(fontSize: 17),
                            ),
                          ),
                          Expanded(child: OutageSocialSection()),
                        ],
                      ),
                    )
                  ],
                ),
              ));
}
