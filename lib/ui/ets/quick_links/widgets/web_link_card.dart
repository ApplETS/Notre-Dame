// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/models/quick_link.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/ets/quick_links/view_model/web_link_card_viewmodel.dart';

class WebLinkCard extends StatelessWidget {
  final QuickLink _links;

  const WebLinkCard(this._links, {super.key});

  @override
  Widget build(BuildContext context) => ViewModelBuilder<WebLinkCardViewModel>.reactive(
    viewModelBuilder: () => WebLinkCardViewModel(),
    builder: (context, model, child) {
      return ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: Card(
          elevation: 4.0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            onTap: () => model.onLinkClicked(_links),
            splashColor: AppPalette.etsLightRed.withAlpha(50),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(color: AppPalette.etsLightRed),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                      child: Center(
                        child: Text(
                          _links.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            height: 0.9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _links.image,
                  ),
                ),
              ],
            ),
            ),
          ),
      );
    },
  );
}
