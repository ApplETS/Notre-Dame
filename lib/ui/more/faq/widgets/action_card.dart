// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/ui/more/faq/models/faq_actions.dart';

class ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final ActionType type;
  final String link;
  final IconData iconName;
  final Color iconColor;
  final Color circleColor;
  final VoidCallback? onTap;

  const ActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.type,
    required this.link,
    required this.iconName,
    required this.iconColor,
    required this.circleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 4.0),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(10.0),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontSize: 18,
                            ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    CircleAvatar(
                      backgroundColor: circleColor,
                      radius: 25,
                      child: Icon(iconName, color: iconColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyLarge!,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
