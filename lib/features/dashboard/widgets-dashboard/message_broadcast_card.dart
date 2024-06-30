import 'package:flutter/material.dart';
import 'package:notredame/features/app/widgets/dismissible_card.dart';

class MessageBroadcastCard extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onDismissed;
  final String broadcastColor;

  const MessageBroadcastCard({
    required this.title,
    required this.content,
    required this.onDismissed,
    required this.broadcastColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final broadcastMsgColor = Color(int.parse(broadcastColor));
    return DismissibleCard(
      key: UniqueKey(),
      onDismissed: (DismissDirection direction) {
        onDismissed();
      },
      cardColor: broadcastMsgColor,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.fromLTRB(17, 15, 0, 0),
              child: Text(title,
                  style: Theme.of(context).primaryTextTheme.titleLarge),
            )),
        Container(
          padding: const EdgeInsets.fromLTRB(17, 0, 17, 8),
          child: Text(content,
              style: Theme.of(context).primaryTextTheme.bodyMedium),
        ),
      ]),
    );
  }
}
