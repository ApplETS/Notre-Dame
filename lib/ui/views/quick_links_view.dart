// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// VIEW-MODEL
import 'package:notredame/core/viewmodels/quick_links_viewmodel.dart';

// WIDGETS
import 'package:notredame/ui/widgets/base_scaffold.dart';
import 'package:notredame/ui/widgets/web_link_card.dart';

// OTHER

class QuickLinksView extends StatefulWidget {
  @override
  _QuickLinksViewState createState() => _QuickLinksViewState();
}

class _QuickLinksViewState extends State<QuickLinksView> {
  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<QuickLinksViewModel>.reactive(
        viewModelBuilder: () => QuickLinksViewModel(AppIntl.of(context)),
        builder: (context, model, child) => BaseScaffold(
          isLoading: model.isBusy,
          appBar: AppBar(
            title: Text(AppIntl.of(context).title_ets),
            automaticallyImplyLeading: false,
          ),
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 8.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: List.generate(
                    model.quickLinkList.length,
                    (index) => WebLinkCard(model.quickLinkList[index]),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
