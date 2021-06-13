// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

// VIEWMODEL
import 'package:notredame/core/viewmodels/web_link_card_viewmodel.dart';

// MODEL
import 'package:notredame/core/models/quick_link.dart';

// UTILS
import 'package:notredame/ui/utils/app_theme.dart';

class WebLinkCard extends StatelessWidget {
  final QuickLink _links;

  const WebLinkCard(this._links);

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<WebLinkCardViewModel>.reactive(
          viewModelBuilder: () => WebLinkCardViewModel(),
          builder: (context, model, child) {
            return SizedBox(
              width: MediaQuery.of(context).size.width / 3.1,
              height: 130,
              child: Card(
                elevation: 4.0,
                child: InkWell(
                  onTap: () => model.onLinkClicked(_links),
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
                                color: Colors.red, fontSize: 18.0),
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
