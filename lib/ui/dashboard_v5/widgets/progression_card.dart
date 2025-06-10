import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/themes/app_palette.dart';

class ProgressionCard extends StatelessWidget {
  final Widget childWidget;

  const ProgressionCard({
    super.key,
    required this.childWidget,
  });

  /// TODO : This class needs to be entirely refactored
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),

      /// TODO : add the right => height: 145,
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        color: AppPalette.grey.darkGrey,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox.square(
            child: childWidget,
          ),
          const SizedBox(height: 10),
          Text(
            'Progression',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: AppPalette.grey.white,
            ),
          ),
        ],
      ),
    );
  }
}
