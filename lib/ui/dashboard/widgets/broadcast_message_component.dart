// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/data/models/broadcast_message.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/dashboard/view_model/dashboard_viewmodel.dart';

class BroadcastMessageComponent extends StatelessWidget {
  final BroadcastMessage? broadcastMessage;
  final TextStyle? style;

  const BroadcastMessageComponent({super.key, this.broadcastMessage, required this.style});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            broadcastMessage!.message,
            style: style,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            textAlign: TextAlign.start,
          ),
        ),
        if (broadcastMessage!.url != "")
          IconButton(
            tooltip: AppIntl.of(context)!.website_open,
            onPressed: () => DashboardViewModel.launchBroadcastUrl(broadcastMessage!.url),
            icon: Icon(Icons.open_in_new, color: context.theme.primaryTextTheme.titleLarge!.color, size: 26.0),
          ),
      ],
    );
  }
}
