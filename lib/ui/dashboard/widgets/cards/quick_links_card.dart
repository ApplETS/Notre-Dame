// Package imports:
import 'package:material_ui/material_ui.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/ui/titled_card.dart';
import 'package:notredame/ui/ets/quick_links/view_model/quick_links_viewmodel.dart';
import 'package:notredame/ui/ets/quick_links/widgets/web_link_card.dart';

class QuickLinksCard extends StatelessWidget {
  const QuickLinksCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<QuickLinksViewModel>.reactive(
      viewModelBuilder: () => QuickLinksViewModel(AppIntl.of(context)!),
      builder: (context, model, child) => TitledCard(
        title: AppIntl.of(context)!.useful_link_title,
        child: Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final int crossAxisCount = (constraints.maxWidth / 100.0).floor().clamp(1, double.infinity).toInt();
              return GridView.count(
                padding: const EdgeInsets.all(8.0),
                mainAxisSpacing: 2.0,
                crossAxisSpacing: 2.0,
                crossAxisCount: crossAxisCount,
                children: model.quickLinkList.map((link) => WebLinkCard(link, key: ValueKey(link.id))).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}
