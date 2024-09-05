// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/app/widgets/broadcast_card/broadcast_card_viewmodel.dart';
import 'package:notredame/utils/app_theme.dart';

class MessageBroadcastCard extends StatelessWidget {
  const MessageBroadcastCard({
    super.key,
  });
  
  @override
  Widget build(BuildContext context) => ViewModelBuilder<BroadcastCardViewmodel>.reactive(
      viewModelBuilder: () => BroadcastCardViewmodel(AppIntl.of(context)!),
      builder: (context, model, child) {
        if (model.data == null || !model.dataReady) {
          return const SizedBox.shrink();
        }
        final broadcastCard = model.data!;
        return Card(
            key: UniqueKey(),
            color: broadcastCard.color,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(17, 10, 15, 20),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // title row
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(broadcastCard.title,
                            style: Theme.of(context)
                                .primaryTextTheme
                                .titleLarge),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        child: getBroadcastIcon(model),
                      ),
                    ),
                  ],
                ),
                // main text
                AutoSizeText(broadcastCard.message,
                    style: Theme.of(context).primaryTextTheme.bodyMedium)
              ]),
            ));
      });

  Widget getBroadcastIcon(BroadcastCardViewmodel model) {
    switch (model.data!.type) {
      case "warning":
        return const Icon(
          Icons.warning_rounded,
          color: AppTheme.lightThemeBackground,
          size: 36.0,
        );
      case "alert":
        return const Icon(
          Icons.error,
          color: AppTheme.lightThemeBackground,
          size: 36.0,
        );
      case "link":
        return IconButton(
          onPressed: () {
            model.launchBroadcastUrl(model.data!.url);
          },
          icon: const Icon(
            Icons.open_in_new,
            color: AppTheme.lightThemeBackground,
            size: 30.0,
          ),
        );
    }
    return const Icon(
      Icons.campaign,
      color: AppTheme.lightThemeBackground,
      size: 36.0,
    );
  }
}
