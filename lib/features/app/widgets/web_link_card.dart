// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/ets/quick-link/models/quick_link.dart';
import 'package:notredame/features/ets/web_link_card_viewmodel.dart';
import 'package:notredame/utils/app_theme.dart';

class WebLinkCard extends StatelessWidget {
  final QuickLink _links;

  const WebLinkCard(this._links);

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<WebLinkCardViewModel>.reactive(
          viewModelBuilder: () => WebLinkCardViewModel(),
          builder: (context, model, child) {
            return ConstrainedBox(
              constraints: const BoxConstraints.expand(),
              child: Card(
                elevation: 4.0,
                child: InkWell(
                  onTap: () =>
                      model.onLinkClicked(_links, Theme.of(context).brightness),
                  splashColor: AppTheme.etsLightRed.withAlpha(50),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 40,
                          child: _links.image,
                        ),
                        FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                            _links.name,
                            style: const TextStyle(
                                color: AppTheme.etsLightRed, fontSize: 18.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
}
