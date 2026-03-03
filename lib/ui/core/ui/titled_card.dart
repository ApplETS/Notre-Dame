// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/ui/core/themes/app_palette.dart';
import '../themes/app_theme.dart';

class TitledCard extends StatelessWidget {
  final Widget _child;
  final String _title;

  const TitledCard({super.key, required String title, required Widget child})
    : _title = title,
      _child = child;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      color: context.theme.appColors.dashboardCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12.0), bottom: Radius.circular(20.0))),
      child: Column(
        children: [
          Container(
            color: AppPalette.etsLightRed,
            height: 36,
            alignment: Alignment.center,
            child: Text(
              _title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          _child,
        ],
      ),
    );
  }
}
