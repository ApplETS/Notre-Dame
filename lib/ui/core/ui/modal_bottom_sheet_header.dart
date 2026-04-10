// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/ui/core/themes/app_theme.dart';

class ModalBottomSheetHeader extends StatelessWidget {
  final Widget title;

  const ModalBottomSheetHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: context.theme.appColors.modalTitle),
      child: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: context.theme.appColors.modalHandle,
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: title),
        ],
      ),
    );
  }
}
