import 'package:flutter/material.dart';
import 'package:notredame/utils/utils.dart';

class LanguageCardWidget extends StatelessWidget {
  final String language;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageCardWidget({
    super.key,
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color:
          Utils.getColorByBrightness(context, Colors.white, Colors.grey[900]!),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(language),
            trailing: Icon(isSelected ? Icons.check : null),
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}
