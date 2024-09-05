// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:notredame/features/app/error/outage/widgets/outage_image_section.dart';
import 'package:notredame/features/app/error/outage/widgets/outage_social_section.dart';
import 'package:notredame/features/app/error/outage/widgets/outage_text_section.dart';
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
                          OutageTextSection(
                              textPlacement: model.getTextPlacement(),
                              buttonPlacement: model.getButtonPlacement(),
                              refreshOutageConfig: model.refreshOutageConfig),
                          Expanded(child: OutageSocialSection()),
                        ],
                      ),
                    )
                  ],
                ),
              ));
}
