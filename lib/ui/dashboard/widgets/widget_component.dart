// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/ui/core/themes/app_palette.dart';

import '../../core/themes/app_theme.dart';

class WidgetComponent extends StatelessWidget {
  final Widget _child;
  final String _title;

  const WidgetComponent({super.key, Widget? child, required String title})
    : _title = title,
      _child =
          child ??
          const SizedBox(
            height: 125,
            child: Text("TODO", style: TextStyle(color: Colors.white)),
          );

  /// TODO : This class needs to be entirely refactored
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      color: context.theme.appColors.dashboardCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Column(
        children: [
          Container(
            color: AppPalette.etsLightRed,
            height: 36,
            alignment: Alignment.center,
            child: Text(
              _title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          _child,
        ],
      ),
    );
  }
}
