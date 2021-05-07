// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

// VIEWMODEL
import 'package:notredame/core/viewmodels/web_link_card_viewmodel.dart';

// MODEL
import 'package:notredame/core/models/quick_link.dart';

// OTHER
import 'package:notredame/ui/utils/app_theme.dart';

class WebLinkCard extends StatefulWidget {
  final QuickLink _links;

  const WebLinkCard(this._links);

  @override
  _WebLinkCardState createState() => _WebLinkCardState();
}

class _WebLinkCardState extends State<WebLinkCard> {
  WebLinkCardViewModel model;

  @override
  void initState() {
    super.initState();
    
    model = WebLinkCardViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3.1,
      height: 130,
      child: Card(
        elevation: 4.0,
        child: InkWell(
          onTap: () => model.onLinkClicked(widget._links),
          splashColor: AppTheme.etsLightRed.withAlpha(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  flex: 40,
                  child: Image.asset(widget._links.image, color: AppTheme.etsLightRed),
                ),
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    widget._links.name,
                    style: const TextStyle(color: Colors.red, fontSize: 18.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
 