// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/theme/app_theme.dart';
import 'package:notredame/ui/outage/view_model/outage_viewmodel.dart';
import 'package:notredame/ui/outage/widgets/outage_image_section.dart';
import 'package:notredame/ui/outage/widgets/outage_social_section.dart';
import 'package:notredame/ui/outage/widgets/outage_text_section.dart';

class OutageView extends StatelessWidget {
  const OutageView({super.key});

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<OutageViewModel>.nonReactive(
          viewModelBuilder: () => OutageViewModel(context),
          builder: (context, model, child) => Scaffold(
                backgroundColor: context.theme.appColors.backgroundVibrant,
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
