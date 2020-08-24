import 'package:flutter/material.dart';
import 'package:notredame/core/viewmodels/quick_links_viewmodel.dart';
import 'package:notredame/generated/l10n.dart';
import 'package:notredame/ui/widgets/web_link_card.dart';
import 'package:stacked/stacked.dart';

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
          ),
          body: Align(
            alignment: const Alignment(0.0, -0.9),
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: List.generate(
                  model.numberOfLinks,
                  (index) => InkWell(
                      splashColor: Colors.red.withAlpha(50),
                      onTap: () => model.onLinkClicked(
                          context, model.quickLinkList[index]),
                      child: WebLinkCard(model.quickLinkList[index])),
                ),
              ),
            ),
          ),
        ),
      );
}
