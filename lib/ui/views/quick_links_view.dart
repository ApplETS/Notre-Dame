// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

// VIEW-MODEL
import 'package:notredame/core/viewmodels/quick_links_viewmodel.dart';

// WIDGETS
import 'package:notredame/ui/widgets/bottom_bar.dart';
import 'package:notredame/ui/widgets/web_link_card.dart';

// OTHER
import 'package:notredame/generated/l10n.dart';

class QuickLinksView extends StatefulWidget {
  @override
  _QuickLinksViewState createState() => _QuickLinksViewState();
}

class _QuickLinksViewState extends State<QuickLinksView> {
  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<QuickLinksViewModel>.reactive(
        viewModelBuilder: () => QuickLinksViewModel(),
        builder: (context, model, child) => Scaffold(
          appBar: AppBar(
            title: Text(AppIntl.of(context).title_ets),
            automaticallyImplyLeading: false,
          ),
          bottomNavigationBar: BottomBar(BottomBar.etsView),
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 8.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: List.generate(
                    model.quickLinkList.length,
                    (index) => InkWell(
                        splashColor: Colors.red.withAlpha(50),
                        onTap: () =>
                            model.onLinkClicked(model.quickLinkList[index]),
                        child: WebLinkCard(model.quickLinkList[index])),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
